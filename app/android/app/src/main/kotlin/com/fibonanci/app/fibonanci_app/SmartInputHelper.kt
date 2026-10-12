package com.fibonanci.app.fibonanci_app

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodChannel
import java.io.File

class SmartInputHelper(private val activity: Activity) {
    companion object {
        const val AUDIO_PERM_REQUEST_CODE = 9402
    }

    private var channel: MethodChannel? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private var pendingLocale: String? = null

    fun attachChannel(methodChannel: MethodChannel) {
        channel = methodChannel
    }

    fun startHeadlessListening(locale: String, result: MethodChannel.Result) {
        if (!SpeechRecognizer.isRecognitionAvailable(activity)) {
            result.success("UNAVAILABLE")
            return
        }
        val granted = ContextCompat.checkSelfPermission(
            activity,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            pendingLocale = locale
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                AUDIO_PERM_REQUEST_CODE
            )
            result.success("PERMISSION_REQUESTED")
            return
        }
        beginListeningInternal(locale)
        result.success("STARTED")
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != AUDIO_PERM_REQUEST_CODE) return false
        val locale = pendingLocale ?: "id-ID"
        pendingLocale = null
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            beginListeningInternal(locale)
        } else {
            channel?.invokeMethod(
                "onSpeechEvent",
                mapOf("type" to "error", "reason" to "permission_denied")
            )
        }
        return true
    }

    private fun beginListeningInternal(locale: String) {
        try {
            speechRecognizer?.destroy()
            val recognizer = SpeechRecognizer.createSpeechRecognizer(activity)
            speechRecognizer = recognizer
            recognizer.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "ready"))
                }
                override fun onBeginningOfSpeech() {
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "speaking"))
                }
                override fun onRmsChanged(rmsdB: Float) {
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "rms", "rms" to rmsdB.toDouble()))
                }
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "processing"))
                }
                override fun onError(error: Int) {
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "error", "code" to error))
                }
                override fun onResults(results: Bundle?) {
                    val text = results
                        ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()
                        ?.trim() ?: ""
                    channel?.invokeMethod("onSpeechEvent", mapOf("type" to "final", "text" to text))
                }
                override fun onPartialResults(partialResults: Bundle?) {
                    val text = partialResults
                        ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()
                        ?.trim() ?: ""
                    if (text.isNotEmpty()) {
                        channel?.invokeMethod("onSpeechEvent", mapOf("type" to "partial", "text" to text))
                    }
                }
                override fun onEvent(eventType: Int, params: Bundle?) {}
            })
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            }
            recognizer.startListening(intent)
        } catch (_: Exception) {
            channel?.invokeMethod("onSpeechEvent", mapOf("type" to "unavailable"))
        }
    }

    fun stopHeadlessListening(result: MethodChannel.Result) {
        try { speechRecognizer?.stopListening() } catch (_: Exception) {}
        result.success(true)
    }

    fun cancelHeadlessListening(result: MethodChannel.Result) {
        try {
            speechRecognizer?.cancel()
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (_: Exception) {}
        result.success(true)
    }

    fun dispose() {
        try {
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (_: Exception) {}
    }

    fun recognizeImageText(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.success(null)
                return
            }
            val image = InputImage.fromFilePath(activity, Uri.fromFile(file))
            val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
            recognizer.process(image)
                .addOnSuccessListener { visionText ->
                    result.success(visionText.text)
                }
                .addOnFailureListener {
                    result.success(null)
                }
        } catch (_: Exception) {
            result.success(null)
        }
    }
}
