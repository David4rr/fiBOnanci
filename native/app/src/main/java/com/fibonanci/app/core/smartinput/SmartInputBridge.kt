package com.fibonanci.app.core.smartinput

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File
import kotlin.coroutines.resume
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.suspendCancellableCoroutine

/** result of [SmartInputBridge.capturePhotoAndExtractText]; canceled is true if the user dismissed the picker. */
data class PhotoOcrResult(val ocrText: String?, val canceled: Boolean)

/**
 * native bridge for 100% on-device offline voice speech-to-text and
 * photo receipt/transfer proof ocr via android SpeechRecognizer & google ml kit.
 * create it in MainActivity.onCreate (launchers are registered in the constructor).
 * callers use the companion api, mirroring the dart static methods.
 */
class SmartInputBridge(private val activity: ComponentActivity) {
    private var speechRecognizer: SpeechRecognizer? = null
    private var speechListener: ((Map<String, Any?>) -> Unit)? = null
    private var pendingLocale: String? = null

    private var pendingCameraPermission: CompletableDeferred<Boolean>? = null
    private var pendingCapture: CompletableDeferred<Boolean>? = null
    private var pendingPick: CompletableDeferred<Uri?>? = null

    private val audioPermissionLauncher: ActivityResultLauncher<String> =
        activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            val locale = pendingLocale ?: "id-ID"
            pendingLocale = null
            if (granted) {
                beginListeningInternal(locale)
            } else {
                emit(mapOf("type" to "error", "reason" to "permission_denied"))
            }
        }

    private val cameraPermissionLauncher: ActivityResultLauncher<String> =
        activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            pendingCameraPermission?.complete(granted)
            pendingCameraPermission = null
        }

    private val takePictureLauncher: ActivityResultLauncher<Uri> =
        activity.registerForActivityResult(ActivityResultContracts.TakePicture()) { saved ->
            pendingCapture?.complete(saved)
            pendingCapture = null
        }

    private val pickMediaLauncher: ActivityResultLauncher<PickVisualMediaRequest> =
        activity.registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
            pendingPick?.complete(uri)
            pendingPick = null
        }

    private fun emit(event: Map<String, Any?>) {
        speechListener?.invoke(event)
    }

    private fun startListening(onEvent: (Map<String, Any?>) -> Unit, locale: String): String {
        speechListener = onEvent
        if (!SpeechRecognizer.isRecognitionAvailable(activity)) return "UNAVAILABLE"
        val granted = ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        if (!granted) {
            pendingLocale = locale
            audioPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO)
            return "PERMISSION_REQUESTED"
        }
        beginListeningInternal(locale)
        return "STARTED"
    }

    private fun beginListeningInternal(locale: String) {
        try {
            speechRecognizer?.destroy()
            val recognizer = SpeechRecognizer.createSpeechRecognizer(activity)
            speechRecognizer = recognizer
            recognizer.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) = emit(mapOf("type" to "ready"))
                override fun onBeginningOfSpeech() = emit(mapOf("type" to "speaking"))
                override fun onRmsChanged(rmsdB: Float) = emit(mapOf("type" to "rms", "rms" to rmsdB.toDouble()))
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() = emit(mapOf("type" to "processing"))
                override fun onError(error: Int) = emit(mapOf("type" to "error", "code" to error))
                override fun onResults(results: Bundle?) {
                    val text = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()?.trim() ?: ""
                    emit(mapOf("type" to "final", "text" to text))
                }
                override fun onPartialResults(partialResults: Bundle?) {
                    val text = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        ?.firstOrNull()?.trim() ?: ""
                    if (text.isNotEmpty()) emit(mapOf("type" to "partial", "text" to text))
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
            emit(mapOf("type" to "unavailable"))
        }
    }

    private fun stopListening() {
        try {
            speechRecognizer?.stopListening()
        } catch (_: Exception) {
        }
    }

    private fun cancelListening() {
        speechListener = null
        try {
            speechRecognizer?.cancel()
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (_: Exception) {
        }
    }

    /** call from MainActivity.onDestroy. */
    fun dispose() {
        try {
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (_: Exception) {
        }
        if (instance === this) instance = null
    }

    private suspend fun pickImage(fromCamera: Boolean): Uri? {
        if (!fromCamera) {
            val deferred = CompletableDeferred<Uri?>()
            pendingPick = deferred
            pickMediaLauncher.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
            return deferred.await()
        }
        // the manifest declares CAMERA, so the capture intent requires it to be granted
        val hasCamera = ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        if (!hasCamera) {
            val permission = CompletableDeferred<Boolean>()
            pendingCameraPermission = permission
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
            if (!permission.await()) throw SecurityException("camera permission denied")
        }
        val dir = File(activity.cacheDir, "captures").apply { mkdirs() }
        val file = File(dir, "capture_${System.currentTimeMillis()}.jpg")
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.fileprovider", file)
        val deferred = CompletableDeferred<Boolean>()
        pendingCapture = deferred
        takePictureLauncher.launch(uri)
        return if (deferred.await() && file.exists() && file.length() > 0) uri else null
    }

    private suspend fun recognizeImageText(uri: Uri): String? {
        val image = InputImage.fromFilePath(activity, uri)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        return suspendCancellableCoroutine { cont ->
            recognizer.process(image)
                .addOnSuccessListener { visionText -> cont.resume(visionText.text) }
                .addOnFailureListener { cont.resume(null) }
        }
    }

    private suspend fun captureAndRecognize(fromCamera: Boolean): PhotoOcrResult {
        return try {
            val uri = pickImage(fromCamera) ?: return PhotoOcrResult(ocrText = null, canceled = true)
            val trimmed = recognizeImageText(uri)?.trim()
            PhotoOcrResult(ocrText = if (!trimmed.isNullOrEmpty()) trimmed else null, canceled = false)
        } catch (_: Exception) {
            PhotoOcrResult(ocrText = null, canceled = false)
        }
    }

    init {
        instance = this
    }

    companion object {
        private var instance: SmartInputBridge? = null

        /** injectable overrides for deterministic testing. */
        var testVoiceOverride: (suspend () -> String?)? = null
        var testPhotoOcrOverride: (suspend (SmartInputSource) -> String?)? = null

        /** returns "STARTED", "PERMISSION_REQUESTED" or "UNAVAILABLE"; events are maps with a "type" key. */
        suspend fun startHeadlessListening(
            onEvent: (Map<String, Any?>) -> Unit,
            locale: String = "id-ID",
        ): String = instance?.startListening(onEvent, locale) ?: "UNAVAILABLE"

        fun stopHeadlessListening() {
            instance?.stopListening()
        }

        fun cancelHeadlessListening() {
            instance?.cancelListening()
        }

        /** captures a photo via camera or selects from gallery, then runs on-device ml kit ocr. */
        suspend fun capturePhotoAndExtractText(fromCamera: Boolean): PhotoOcrResult {
            val source = if (fromCamera) SmartInputSource.camera else SmartInputSource.gallery
            testPhotoOcrOverride?.let { override ->
                val text = override(source)
                return PhotoOcrResult(ocrText = text, canceled = text == null)
            }
            return instance?.captureAndRecognize(fromCamera) ?: PhotoOcrResult(ocrText = null, canceled = false)
        }
    }
}
