package com.fibonanci.app.ui.transaction

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.KeyboardAlt
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.GraphicEq
import androidx.compose.material.icons.rounded.Mic
import androidx.compose.material.icons.rounded.MicNone
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.smartinput.SmartInputBridge
import com.fibonanci.app.core.smartinput.SmartInputSource
import com.fibonanci.app.ui.common.AppTextField
import com.fibonanci.app.ui.common.IPhoneViewportContainer
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.common.PrimaryActionButton
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// onResult gets the submitted text, or null when the sheet closes without a submit (dart pop without value)
fun showSmartInputFallbackSheet(host: ModalHost, source: SmartInputSource, onResult: (String?) -> Unit) {
    host.show(ModalKind.Sheet) { dismiss ->
        var delivered by remember { mutableStateOf(false) }
        DisposableEffect(Unit) {
            onDispose { if (!delivered) onResult(null) }
        }
        SmartInputFallbackSheet(
            source = source,
            onDismiss = dismiss,
            onSubmit = { text ->
                delivered = true
                onResult(text)
                dismiss()
            },
        )
    }
}

private object NominalHighlight {
    private val incomeRx = Regex(
        """\b(gaji|gajian|upah|honor|tunjangan|bonus|thr|terima|menerima|diterima|dapat|mendapat|mendapatkan|dapet|masuk|pemasukan|pendapatan|penghasilan|income|refund|cashback|reimburse|dividen|komisi|insentif|jualan|penjualan|untung|laba|profit|hadiah|cair|pencairan|kiriman|dikasih|ditransfer)\b""",
        RegexOption.IGNORE_CASE,
    )
    private val nominalRx = Regex(
        """(?:(?:rp|idr)\.?\s*)?(?:\d+(?:[.,]\d+)*(?:\s*(?:ribu|rb|k|juta|jt|ratus|puluh))?|\b(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|setengah)(?:\s+(?:satu|dua|tiga|empat|lima|enam|tujuh|delapan|sembilan|sepuluh|sebelas|belas|puluh|seratus|ratus|seribu|ribu|sejuta|juta|setengah))*\b)""",
        RegexOption.IGNORE_CASE,
    )

    fun buildHighlightedSpan(src: String): AnnotatedString {
        val nominalColor = if (incomeRx.containsMatchIn(src)) AppColors.neoMint else AppColors.statusDeficit
        return buildAnnotatedString {
            var cursor = 0
            for (m in nominalRx.findAll(src)) {
                if (m.range.first > cursor) append(src.substring(cursor, m.range.first))
                withStyle(SpanStyle(color = nominalColor, fontWeight = FontWeight.ExtraBold)) { append(m.value) }
                cursor = m.range.last + 1
            }
            if (cursor < src.length) append(src.substring(cursor))
        }
    }
}

// minimalist obsidian voice capture modal using headless on-device speech recognizer
// with live waveform pulse, real-time transcript, and clean keyboard toggle.
@Composable
fun SmartInputFallbackSheet(
    source: SmartInputSource,
    onDismiss: () -> Unit,
    onSubmit: (String) -> Unit,
) {
    val haptic = LocalHapticFeedback.current
    val scope = rememberCoroutineScope()
    var controllerText by remember { mutableStateOf("") }
    var isListening by remember { mutableStateOf(false) }
    var showKeyboard by remember { mutableStateOf(source != SmartInputSource.voice) }
    var rms by remember { mutableFloatStateOf(0f) }
    var transcript by remember { mutableStateOf("") }
    var autoDoneTimer by remember { mutableStateOf<Job?>(null) }

    fun submit() {
        val text = (if (showKeyboard) controllerText else transcript).trim()
        if (text.isEmpty()) return
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        onSubmit(text)
    }

    fun startVoice() {
        isListening = true
        rms = 0.2f
        scope.launch {
            val status = SmartInputBridge.startHeadlessListening(
                onEvent = { event ->
                    val type = event["type"] as? String ?: ""
                    val text = (event["text"] as? String ?: "").trim()
                    when (type) {
                        "partial" -> {
                            transcript = text
                            controllerText = text
                        }
                        "final" -> {
                            isListening = false
                            rms = 0f
                            if (text.isNotEmpty()) {
                                transcript = text
                                controllerText = text
                            }
                            if (transcript.isNotEmpty()) {
                                autoDoneTimer?.cancel()
                                autoDoneTimer = scope.launch {
                                    delay(280)
                                    submit()
                                }
                            }
                        }
                        "rms" -> {
                            val raw = (event["rms"] as? Number)?.toFloat() ?: 0f
                            rms = ((raw + 2f) / 12f).coerceIn(0.05f, 1f)
                        }
                        "unavailable", "error" -> {
                            isListening = false
                            rms = 0f
                        }
                    }
                },
            )
            if (status == "UNAVAILABLE") isListening = false
        }
    }

    LaunchedEffect(Unit) {
        if (source == SmartInputSource.voice) startVoice()
    }
    DisposableEffect(Unit) {
        onDispose {
            autoDoneTimer?.cancel()
            SmartInputBridge.cancelHeadlessListening()
        }
    }

    val hasText = (if (showKeyboard) controllerText else transcript).trim().isNotEmpty()
    val ringSize by animateDpAsState((76f + if (isListening) rms * 26f else 0f).dp, tween(120), label = "ring")

    IPhoneViewportContainer {
        Box(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, bottom = 20.dp)) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(AppColors.canvasCardSurface, RoundedCornerShape(28.dp))
                    .border(1.dp, AppColors.canvasBorder, RoundedCornerShape(28.dp))
                    .padding(start = 22.dp, top = 20.dp, end = 22.dp, bottom = 22.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier
                            .size(8.dp)
                            .background(if (isListening) AppColors.neoChartreuse else AppColors.textMuted, CircleShape),
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(
                        if (isListening) "Mendengarkan..." else "Input Suara",
                        style = AppTypography.listSubtitle.copy(fontSize = 12.5.sp, fontWeight = FontWeight.SemiBold, color = AppColors.textMuted),
                    )
                    Spacer(Modifier.weight(1f))
                    Icon(
                        if (showKeyboard) Icons.Rounded.MicNone else Icons.Outlined.KeyboardAlt,
                        null,
                        Modifier
                            .size(19.dp)
                            .clickable(remember { MutableInteractionSource() }, null) { showKeyboard = !showKeyboard },
                        tint = AppColors.textMuted,
                    )
                    Spacer(Modifier.width(14.dp))
                    Icon(
                        Icons.Rounded.Close,
                        null,
                        Modifier.size(19.dp).clickable(remember { MutableInteractionSource() }, null, onClick = onDismiss),
                        tint = AppColors.textMuted,
                    )
                }
                Spacer(Modifier.height(24.dp))
                if (!showKeyboard) {
                    Box(
                        Modifier
                            .size(104.dp)
                            .clickable(remember { MutableInteractionSource() }, null) {
                                if (isListening) SmartInputBridge.stopHeadlessListening() else startVoice()
                            },
                        contentAlignment = Alignment.Center,
                    ) {
                        Box(
                            Modifier
                                .size(ringSize)
                                .background(AppColors.neoChartreuse.copy(alpha = if (isListening) 0.12f else 0.04f), CircleShape),
                            contentAlignment = Alignment.Center,
                        ) {
                            Box(
                                Modifier
                                    .size(60.dp)
                                    .background(if (isListening) AppColors.neoChartreuse else AppColors.canvasInputSearch, CircleShape)
                                    .border(1.4.dp, AppColors.neoChartreuse, CircleShape),
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(
                                    if (isListening) Icons.Rounded.GraphicEq else Icons.Rounded.Mic,
                                    null,
                                    Modifier.size(26.dp),
                                    tint = if (isListening) AppColors.textDarkPrimary else AppColors.neoChartreuse,
                                )
                            }
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    if (transcript.isEmpty()) {
                        Text(
                            "Ucapkan transaksi Anda...",
                            textAlign = TextAlign.Center,
                            style = AppTypography.listSubtitle.copy(fontSize = 14.sp, color = AppColors.textMuted),
                        )
                    } else {
                        Text(
                            NominalHighlight.buildHighlightedSpan(transcript),
                            textAlign = TextAlign.Center,
                            style = AppTypography.listTitle.copy(fontSize = 16.sp, fontWeight = FontWeight.SemiBold),
                        )
                    }
                } else {
                    AppTextField(
                        value = controllerText,
                        onValueChange = { controllerText = it },
                        maxLines = 2,
                        hintText = "Ketik kalimat transaksi...",
                        onChanged = { transcript = it },
                    )
                }
                if (hasText) {
                    Spacer(Modifier.height(20.dp))
                    PrimaryActionButton(text = "Lanjutkan", onPressed = { submit() })
                }
            }
        }
    }
}
