package com.fibonanci.app.ui.settings

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextRange
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.ui.FinanceState
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

// flutter GestureDetector: tap without ripple
internal fun Modifier.plainClickable(onClick: () -> Unit): Modifier =
    clickable(interactionSource = null, indication = null, onClick = onClick)

object SettingsStyle {
    val title = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.5.sp, fontWeight = FontWeight.W500, color = Color.White.copy(alpha = 0.90f))
    val sub = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.5.sp, fontWeight = FontWeight.W400, color = AppColors.textMuted)
    val value = TextStyle(fontFamily = PlusJakartaSans, fontSize = 13.sp, fontWeight = FontWeight.W500, color = Color.White.copy(alpha = 0.55f), fontFeatureSettings = "tnum")
    val accent = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.5.sp, fontWeight = FontWeight.W600, color = AppColors.neoChartreuse, fontFeatureSettings = "tnum")

    @Composable
    fun sectionHeader(text: String, color: Color? = null) {
        Text(
            text,
            style = TextStyle(
                fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.W700,
                color = color ?: Color.White.copy(alpha = 0.36f), letterSpacing = 1.0.sp,
            ),
        )
    }

    @Composable
    fun hairline(vertical: Float = 0f) {
        Spacer(Modifier.height(vertical.dp))
    }

    @Composable
    fun segmentedTrack(children: @Composable RowScope.() -> Unit) {
        Row(
            Modifier
                .background(Color.White.copy(alpha = 0.035f), RoundedCornerShape(10.dp))
                .padding(3.dp),
            content = children,
        )
    }

    @Composable
    fun switchRow(switchKey: String, title: String, value: Boolean, onChanged: (Boolean) -> Unit) {
        Row(
            Modifier.fillMaxWidth().padding(vertical = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(title, style = SettingsStyle.title, modifier = Modifier.weight(1f, fill = false))
            Switch(
                checked = value,
                onCheckedChange = onChanged,
                colors = SwitchDefaults.colors(checkedTrackColor = AppColors.neoChartreuse),
                modifier = Modifier
                    .testTag(switchKey)
                    .graphicsLayer {
                        scaleX = 0.85f
                        scaleY = 0.85f
                        transformOrigin = TransformOrigin(1f, 0.5f)
                    },
            )
        }
    }

    @Composable
    fun menuRow(
        key: String? = null,
        title: String,
        valueText: String,
        onTap: () -> Unit,
        titleColor: Color? = null,
        valueColor: Color? = null,
        trailingAction: (@Composable () -> Unit)? = null,
    ) {
        Row(
            Modifier
                .then(if (key != null) Modifier.testTag(key) else Modifier)
                .fillMaxWidth()
                .plainClickable(onTap)
                .padding(vertical = 13.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(title, style = if (titleColor != null) SettingsStyle.title.copy(color = titleColor) else SettingsStyle.title, modifier = Modifier.weight(1f))
            if (trailingAction != null) {
                trailingAction()
                Spacer(Modifier.width(10.dp))
            }
            Text(valueText, style = if (valueColor != null) value.copy(color = valueColor) else value)
            Spacer(Modifier.width(4.dp))
            Icon(Icons.Rounded.ChevronRight, contentDescription = null, modifier = Modifier.size(17.dp), tint = valueColor ?: Color.White.copy(alpha = 0.24f))
        }
    }

    @Composable
    fun optionRow(key: String? = null, title: String, subtitle: String? = null, selected: Boolean, onTap: () -> Unit) {
        Row(
            Modifier
                .then(if (key != null) Modifier.testTag(key) else Modifier)
                .fillMaxWidth()
                .plainClickable(onTap)
                .padding(vertical = 13.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(Modifier.weight(1f)) {
                Text(
                    title,
                    style = SettingsStyle.title.copy(
                        color = if (selected) AppColors.textWhite else Color.White.copy(alpha = 0.70f),
                        fontWeight = if (selected) FontWeight.W600 else FontWeight.W500,
                    ),
                )
                if (subtitle != null) {
                    Spacer(Modifier.height(2.dp))
                    Text(subtitle, style = sub)
                }
            }
            if (selected) Icon(Icons.Rounded.Check, contentDescription = null, modifier = Modifier.size(18.dp), tint = AppColors.neoChartreuse)
        }
    }

    @Composable
    fun flatChip(key: String? = null, label: String, selected: Boolean, onTap: () -> Unit) {
        val bg by animateColorAsState(if (selected) Color.White.copy(alpha = 0.12f) else Color.White.copy(alpha = 0.03f), tween(150), label = "chip_bg")
        val border by animateColorAsState(if (selected) Color.White.copy(alpha = 0.22f) else Color.Transparent, tween(150), label = "chip_border")
        val shape = RoundedCornerShape(8.dp)
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans, fontSize = 11.5.sp,
                fontWeight = if (selected) FontWeight.W600 else FontWeight.W500,
                color = if (selected) AppColors.textWhite else AppColors.textMuted,
            ),
            modifier = Modifier
                .then(if (key != null) Modifier.testTag(key) else Modifier)
                .plainClickable(onTap)
                .background(bg, shape)
                .border(0.8.dp, border, shape)
                .padding(horizontal = 11.dp, vertical = 6.dp),
        )
    }
}

// port of the repeated dart TextField + underline InputDecoration used across the settings sub pages
@Composable
internal fun SettingsUnderlineField(
    value: TextFieldValue,
    onValueChange: (TextFieldValue) -> Unit,
    textStyle: TextStyle,
    hintText: String,
    hintStyle: TextStyle,
    modifier: Modifier = Modifier,
    prefixText: String? = null,
    prefixStyle: TextStyle = SettingsStyle.sub,
    numberKeyboard: Boolean = false,
    rupiahFormat: Boolean = false,
    autofocus: Boolean = false,
    enabledBorderAlpha: Float = 0.12f,
    contentPadding: PaddingValues = PaddingValues(vertical = 8.dp),
) {
    var focused by remember { mutableStateOf(false) }
    val focusRequester = remember { FocusRequester() }
    if (autofocus) LaunchedEffect(Unit) { focusRequester.requestFocus() }
    val lineColor = if (focused) AppColors.neoChartreuse else Color.White.copy(alpha = enabledBorderAlpha)
    BasicTextField(
        value = value,
        onValueChange = { next -> onValueChange(if (rupiahFormat) RupiahInputFormatter.formatEditUpdate(value, next) else next) },
        textStyle = textStyle,
        singleLine = true,
        cursorBrush = SolidColor(AppColors.neoChartreuse),
        keyboardOptions = if (numberKeyboard) KeyboardOptions(keyboardType = KeyboardType.Number) else KeyboardOptions.Default,
        modifier = modifier
            .focusRequester(focusRequester)
            .onFocusChanged { focused = it.isFocused },
        decorationBox = { inner ->
            Row(
                Modifier
                    .fillMaxWidth()
                    .drawBehind {
                        val w = if (focused) 2.dp.toPx() else 1.dp.toPx()
                        drawLine(lineColor, Offset(0f, size.height - w / 2), Offset(size.width, size.height - w / 2), w)
                    }
                    .padding(contentPadding),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (prefixText != null && (focused || value.text.isNotEmpty())) Text(prefixText, style = prefixStyle)
                Box(Modifier.weight(1f)) {
                    if (value.text.isEmpty()) Text(hintText, style = hintStyle)
                    inner()
                }
            }
        },
    )
}

internal fun textValue(text: String) = TextFieldValue(text, TextRange(text.length))

@Composable
fun SettingsBudgetCycleSection(state: FinanceState, onNavigate: (SettingsSubRoute) -> Unit) {
    val wallets = state.wallets
    val selectedIds = state.safeToSpendWalletIds ?: emptySet()
    val isAllWallets = state.metrics.isAllWallets
    Column {
        SettingsStyle.menuRow(
            key = "settings_cycle_day_menu_row", title = "Tanggal Mulai Siklus",
            valueText = "Tgl ${state.budgetCycleDay} (${state.metrics.daysRemainingInMonth} hr)",
            onTap = { onNavigate(SettingsSubRoute.cycleDay) },
        )
        if (wallets.isNotEmpty()) {
            SettingsStyle.menuRow(
                key = "settings_sts_wallets_menu_row", title = "Rekening Safe-to-Spend",
                valueText = if (isAllWallets) "Semua (${wallets.size})" else "${selectedIds.size} Aktif",
                onTap = { onNavigate(SettingsSubRoute.stsWallets) },
            )
        }
    }
}

private val cycleDayPresets = listOf(1, 5, 15, 25, 28)

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun SettingsCycleDaySubPage(state: FinanceState) {
    val vm = LocalFinance.current
    var ctrl by rememberSaveable(stateSaver = TextFieldValue.Saver) { mutableStateOf(textValue("${state.budgetCycleDay}")) }
    val cur = state.budgetCycleDay

    fun setDay(d: Int) {
        val clamped = d.coerceIn(1, 31)
        ctrl = textValue("$clamped")
        vm.setBudgetCycleDay(clamped)
    }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item { SettingsStyle.sectionHeader("PRESET TANGGAL SIKLUS") }
        item { Spacer(Modifier.height(6.dp)) }
        items(cycleDayPresets.size) { i ->
            val p = cycleDayPresets[i]
            SettingsStyle.optionRow(key = "settings_cycle_day_$p", title = "Tanggal $p setiap bulan", selected = cur == p, onTap = { setDay(p) })
        }
        item { Spacer(Modifier.height(20.dp)) }
        item { SettingsStyle.sectionHeader("TANGGAL KUSTOM (1–31)") }
        item { Spacer(Modifier.height(10.dp)) }
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                SettingsUnderlineField(
                    value = ctrl, onValueChange = { ctrl = it }, textStyle = SettingsStyle.title,
                    prefixText = "Tanggal ", hintText = "1 - 31", hintStyle = SettingsStyle.sub,
                    numberKeyboard = true, modifier = Modifier.weight(1f).testTag("settings_custom_cycle_day_input"),
                )
                Spacer(Modifier.width(12.dp))
                Text(
                    "Terapkan", style = SettingsStyle.accent,
                    modifier = Modifier.testTag("settings_custom_cycle_day_save").plainClickable {
                        ctrl.text.trim().toIntOrNull()?.let { setDay(it) }
                    },
                )
            }
        }
        item { Spacer(Modifier.height(14.dp)) }
        item {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                for (d in 1..31) {
                    SettingsStyle.flatChip(key = "settings_cycle_grid_$d", label = "$d", selected = cur == d, onTap = { setDay(d) })
                }
            }
        }
        item { Spacer(Modifier.height(16.dp)) }
        item { Text("${state.metrics.daysRemainingInMonth} hari tersisa pada siklus berjalan saat ini.", style = SettingsStyle.sub) }
    }
}

@Composable
fun SettingsStsWalletsSubPage(state: FinanceState) {
    val vm = LocalFinance.current
    val wallets = state.wallets
    val selectedIds = state.safeToSpendWalletIds ?: emptySet()
    val isAllWallets = state.metrics.isAllWallets
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(start = 24.dp, top = 12.dp, end = 24.dp, bottom = 48.dp)) {
        item { SettingsStyle.sectionHeader("REKENING DANA OPERASIONAL") }
        item { Spacer(Modifier.height(6.dp)) }
        item {
            SettingsStyle.optionRow(
                key = "settings_sts_wallet_all", title = "Semua Rekening (${wallets.size})",
                selected = isAllWallets, onTap = { vm.setSafeToSpendWallets(null) },
            )
        }
        items(wallets.size) { i ->
            val w = wallets[i]
            SettingsStyle.optionRow(
                key = "settings_sts_wallet_${w.id}", title = w.name, selected = !isAllWallets && selectedIds.contains(w.id),
                onTap = {
                    val sel = !isAllWallets && selectedIds.contains(w.id)
                    val next = if (isAllWallets) mutableSetOf(w.id) else selectedIds.toMutableSet()
                    if (!isAllWallets) { if (sel) next.remove(w.id) else next.add(w.id) }
                    vm.setSafeToSpendWallets(if (next.isEmpty() || next.size >= wallets.size) null else next)
                },
            )
        }
    }
}
