@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalMaterial3ExpressiveApi::class, ExperimentalLayoutApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccountBalance
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Payments
import androidx.compose.material.icons.rounded.Smartphone
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ButtonGroupDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemColors
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.ListItemShapes
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.ToggleButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.format.RupiahInputFormatter
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceState
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale
import kotlinx.coroutines.launch

val indonesian: Locale = Locale.forLanguageTag("id-ID")

// money figures share one look: the mono face with tabular digits so columns line up
fun TextStyle.money(): TextStyle = copy(fontFamily = AtelierFonts.mono, fontFeatureSettings = "tnum")

// formats base idr for display, masked while the user hides their balance
fun money(state: FinanceState, idr: Double, sign: String = ""): String =
    if (state.isBalanceHidden) AppCurrency.symbolFor(state.profile.currency) + "••••••"
    else AppCurrency.format(idr, state.profile.currency, sign)

fun walletIcon(type: String): ImageVector = when (type) {
    "ewallet" -> Icons.Rounded.Smartphone
    "cash" -> Icons.Rounded.Payments
    else -> Icons.Rounded.AccountBalance
}

fun walletTypeLabel(type: String): String = when (type) {
    "bank" -> "Bank"
    "ewallet" -> "E-wallet"
    "cash" -> "Tunai"
    "investment" -> "Investasi"
    else -> "Lainnya"
}

fun walletName(state: FinanceState, id: String?): String =
    state.wallets.firstOrNull { it.id == id }?.name ?: "Rekening terhapus"

// a bill counts as paid once its last payment landed inside the current calendar month
fun isPaidThisMonth(sub: SubscriptionEntry): Boolean {
    val paid = sub.lastPaidDate ?: return false
    return paid >= LocalDate.now().withDayOfMonth(1).toEpochMillis()
}

fun isPayable(sub: SubscriptionEntry): Boolean = sub.status == "active" && !isPaidThisMonth(sub)

fun dayLabel(millis: Long): String {
    val date = millis.toLocalDate()
    val today = LocalDate.now()
    return when (date) {
        today -> "Hari ini"
        today.minusDays(1) -> "Kemarin"
        else -> date.format(DateTimeFormatter.ofPattern("d MMMM yyyy", indonesian))
    }
}

// shapes for one row of a grouped list: large outer corners, small ones between rows
@Composable
fun groupShapes(index: Int, count: Int): ListItemShapes =
    if (count == 1) {
        ListItemDefaults.shapes(shape = MaterialTheme.shapes.large)
    } else {
        ListItemDefaults.segmentedShapes(index, count, ListItemDefaults.shapes(shape = MaterialTheme.shapes.extraSmall))
    }

@Composable
fun groupColors(container: Color = MaterialTheme.colorScheme.surfaceContainer): ListItemColors =
    ListItemDefaults.segmentedColors(containerColor = container)

// icon sitting in a tinted material shape, used as the leading visual of rows and empty states
@Composable
fun ShapeBadge(icon: ImageVector, container: Color, content: Color, shape: Shape, size: Dp = 40.dp) {
    Surface(modifier = Modifier.size(size), shape = shape, color = container, contentColor = content) {
        Box(contentAlignment = Alignment.Center) {
            Icon(icon, contentDescription = null, modifier = Modifier.size(size * 0.55f))
        }
    }
}

// modal sheet frame shared by every flow; `close` hides the sheet, runs the action, then drops it
@Composable
fun SimpleSheet(
    title: String,
    onDismiss: () -> Unit,
    content: @Composable ColumnScope.(close: (after: () -> Unit) -> Unit) -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()
    val close: (() -> Unit) -> Unit = { after ->
        scope.launch { sheetState.hide() }.invokeOnCompletion {
            after()
            onDismiss()
        }
    }
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(start = 24.dp, end = 24.dp, bottom = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Text(title, style = MaterialTheme.typography.headlineSmallEmphasized)
            content(close)
        }
    }
}

@Composable
fun PrimaryAction(text: String, enabled: Boolean, onClick: () -> Unit) {
    val height = ButtonDefaults.MediumContainerHeight
    Button(
        onClick = onClick,
        shapes = ButtonDefaults.shapesFor(height),
        enabled = enabled,
        modifier = Modifier.fillMaxWidth().heightIn(min = height),
        contentPadding = ButtonDefaults.contentPaddingFor(height),
    ) {
        Text(text, style = ButtonDefaults.textStyleFor(height))
    }
}

@Composable
fun DestructiveAction(text: String, onClick: () -> Unit) {
    TextButton(
        onClick = onClick,
        shapes = ButtonDefaults.shapes(),
        colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Icon(Icons.Rounded.DeleteOutline, contentDescription = null, modifier = Modifier.size(ButtonDefaults.IconSize))
        Spacer(Modifier.width(ButtonDefaults.IconSpacing))
        Text(text)
    }
}

@Composable
fun ConfirmDialog(
    title: String,
    text: String,
    confirmLabel: String,
    destructive: Boolean,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = { Text(text) },
        confirmButton = {
            TextButton(
                onClick = onConfirm,
                colors = if (destructive) ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                else ButtonDefaults.textButtonColors(),
            ) { Text(confirmLabel) }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Batal") } },
    )
}

@Composable
fun PayDialog(sub: SubscriptionEntry, state: FinanceState, onConfirm: () -> Unit, onDismiss: () -> Unit) {
    ConfirmDialog(
        title = "Bayar tagihan?",
        text = "Bayar ${sub.title} ${money(state, sub.cost)} dari ${walletName(state, sub.walletId)}?",
        confirmLabel = "Bayar",
        destructive = false,
        onConfirm = onConfirm,
        onDismiss = onDismiss,
    )
}

// connected button group for picking one of two to four options
@Composable
fun <T> ConnectedChoice(options: List<Pair<T, String>>, selected: T, onSelect: (T) -> Unit, modifier: Modifier = Modifier) {
    val haptic = LocalHapticFeedback.current
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(ButtonGroupDefaults.ConnectedSpaceBetween),
    ) {
        options.forEachIndexed { index, (value, label) ->
            ToggleButton(
                checked = value == selected,
                onCheckedChange = {
                    if (value != selected) haptic.performHapticFeedback(HapticFeedbackType.SegmentTick)
                    onSelect(value)
                },
                modifier = Modifier.weight(1f).semantics { role = Role.RadioButton },
                shapes = when (index) {
                    0 -> ButtonGroupDefaults.connectedLeadingButtonShapes()
                    options.lastIndex -> ButtonGroupDefaults.connectedTrailingButtonShapes()
                    else -> ButtonGroupDefaults.connectedMiddleButtonShapes()
                },
            ) {
                Text(label, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }
        }
    }
}

// outlined amount input with live thousand separators
@Composable
fun AmountField(
    value: TextFieldValue,
    onValueChange: (TextFieldValue) -> Unit,
    label: String,
    currency: String,
    modifier: Modifier = Modifier,
    supporting: String? = null,
    isError: Boolean = false,
    imeAction: ImeAction = ImeAction.Done,
) {
    OutlinedTextField(
        value = value,
        onValueChange = { onValueChange(RupiahInputFormatter.formatEditUpdate(value, it)) },
        modifier = modifier.fillMaxWidth(),
        label = { Text(label) },
        prefix = { Text(AppCurrency.symbolFor(currency)) },
        textStyle = MaterialTheme.typography.bodyLarge.money(),
        supportingText = if (supporting != null) {
            { Text(supporting) }
        } else {
            null
        },
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = imeAction),
    )
}

// wallet picker as filter chips; `error` explains when nothing can be picked
@Composable
fun WalletChips(
    title: String,
    wallets: List<WalletEntry>,
    selectedId: String?,
    onSelect: (String) -> Unit,
    error: String? = null,
) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(title, style = MaterialTheme.typography.titleSmall)
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            wallets.forEach { wallet ->
                val selected = wallet.id == selectedId
                FilterChip(
                    selected = selected,
                    onClick = { onSelect(wallet.id) },
                    label = { Text(wallet.name) },
                    leadingIcon = {
                        Icon(
                            if (selected) Icons.Rounded.Check else walletIcon(wallet.type),
                            contentDescription = null,
                            modifier = Modifier.size(FilterChipDefaults.IconSize),
                        )
                    },
                )
            }
        }
        if (error != null) {
            Text(error, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.error)
        }
    }
}

// read-only grouped details, label above value
@Composable
fun DetailGroup(rows: List<Pair<String, String>>) {
    Column(verticalArrangement = Arrangement.spacedBy(ListItemDefaults.SegmentedGap)) {
        rows.forEachIndexed { index, (label, value) ->
            ListItem(
                headlineContent = { Text(value) },
                overlineContent = { Text(label) },
                modifier = Modifier.clip(groupShapes(index, rows.size).shape),
                colors = ListItemDefaults.colors(containerColor = MaterialTheme.colorScheme.surfaceContainerHigh),
            )
        }
    }
}
