@file:OptIn(ExperimentalMaterial3ExpressiveApi::class)

package com.fibonanci.app.ui.simple

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.ArrowDownward
import androidx.compose.material.icons.rounded.ArrowUpward
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.EventRepeat
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.LinearWavyProgressIndicator
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.MaterialShapes
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SegmentedListItem
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.toShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.FinanceState
import java.time.LocalDate

@Composable
fun HeroCard(state: FinanceState, modifier: Modifier = Modifier) {
    val metrics = state.metrics
    val today = LocalDate.now()
    val daysInMonth = today.lengthOfMonth()
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.extraLarge,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer,
            contentColor = MaterialTheme.colorScheme.onPrimaryContainer,
        ),
    ) {
        Column(Modifier.padding(24.dp)) {
            Text("Aman dipakai bulan ini", style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(8.dp))
            AnimatedMoney(
                amount = metrics.safeToSpendMonthly,
                text = money(state, metrics.safeToSpendMonthly),
                style = MaterialTheme.typography.displayMediumEmphasized.money(),
            )
            Spacer(Modifier.height(8.dp))
            Text(
                "Saldo ${money(state, metrics.totalRealBalance)} − tagihan belum dibayar ${money(state, metrics.pendingBills)}",
                style = MaterialTheme.typography.bodyMedium,
                color = LocalContentColor.current.copy(alpha = 0.8f),
            )
            Spacer(Modifier.height(20.dp))
            HorizontalDivider(color = LocalContentColor.current.copy(alpha = 0.16f))
            Spacer(Modifier.height(16.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                HeroStat(
                    value = "≈ ${money(state, metrics.safeToSpendDaily)} / hari",
                    caption = "Jatah harian",
                    modifier = Modifier.weight(1f),
                )
                HeroStat(
                    value = "${metrics.daysRemainingInMonth} hari lagi",
                    caption = if (state.budgetCycleDay <= 1) "Sampai akhir bulan" else "Sampai tanggal ${state.budgetCycleDay}",
                    modifier = Modifier.weight(1f),
                )
            }
            Spacer(Modifier.height(20.dp))
            LinearWavyProgressIndicator(
                progress = { today.dayOfMonth.toFloat() / daysInMonth },
                modifier = Modifier.fillMaxWidth(),
                trackColor = LocalContentColor.current.copy(alpha = 0.2f),
            )
            Spacer(Modifier.height(8.dp))
            Text(
                "Hari ke-${today.dayOfMonth} dari $daysInMonth bulan ini",
                style = MaterialTheme.typography.labelMedium,
                color = LocalContentColor.current.copy(alpha = 0.8f),
            )
        }
    }
}

@Composable
private fun HeroStat(value: String, caption: String, modifier: Modifier = Modifier) {
    Column(modifier) {
        Text(
            value,
            style = MaterialTheme.typography.titleMedium.money(),
            maxLines = 1,
            autoSize = TextAutoSize.StepBased(
                minFontSize = MaterialTheme.typography.labelMedium.fontSize,
                maxFontSize = MaterialTheme.typography.titleMedium.fontSize,
            ),
        )
        Text(caption, style = MaterialTheme.typography.labelMedium, color = LocalContentColor.current.copy(alpha = 0.8f))
    }
}

// the hero figure rolls up when it grows and down when it shrinks
@Composable
private fun AnimatedMoney(amount: Double, text: String, style: TextStyle) {
    val spatial = MaterialTheme.motionScheme.defaultSpatialSpec<IntOffset>()
    val effects = MaterialTheme.motionScheme.defaultEffectsSpec<Float>()
    val minSize = MaterialTheme.typography.headlineSmall.fontSize
    AnimatedContent(
        targetState = amount to text,
        modifier = Modifier.fillMaxWidth(),
        transitionSpec = {
            val up = targetState.first > initialState.first
            (slideInVertically(spatial) { if (up) it else -it } + fadeIn(effects))
                .togetherWith(slideOutVertically(spatial) { if (up) -it else it } + fadeOut(effects))
                .using(SizeTransform(clip = false))
        },
        label = "safe-to-spend",
    ) { (_, shown) ->
        Text(
            shown,
            modifier = Modifier.fillMaxWidth(),
            style = style,
            maxLines = 1,
            autoSize = TextAutoSize.StepBased(minFontSize = minSize, maxFontSize = style.fontSize),
        )
    }
}

@Composable
fun SectionHeader(title: String, modifier: Modifier = Modifier, action: String? = null, onAction: () -> Unit = {}) {
    Row(
        modifier = modifier.fillMaxWidth().padding(start = 4.dp, top = 20.dp, bottom = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            title,
            style = MaterialTheme.typography.titleMediumEmphasized,
            modifier = Modifier.weight(1f).semantics { heading() },
        )
        if (action != null) {
            TextButton(onClick = onAction, shapes = ButtonDefaults.shapes()) {
                Icon(Icons.Rounded.Add, contentDescription = null, modifier = Modifier.size(ButtonDefaults.IconSize))
                Spacer(Modifier.width(ButtonDefaults.IconSpacing))
                Text(action)
            }
        }
    }
}

@Composable
fun DayHeader(label: String) {
    Surface(color = MaterialTheme.colorScheme.surface, modifier = Modifier.fillMaxWidth()) {
        Text(
            label,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(start = 4.dp, top = 12.dp, bottom = 6.dp).semantics { heading() },
        )
    }
}

@Composable
fun EmptyGroup(icon: ImageVector, title: String, hint: String, modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surfaceContainer,
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ShapeBadge(
                icon = icon,
                container = MaterialTheme.colorScheme.secondaryContainer,
                content = MaterialTheme.colorScheme.onSecondaryContainer,
                shape = MaterialShapes.SoftBurst.toShape(),
                size = 56.dp,
            )
            Spacer(Modifier.height(12.dp))
            Text(title, style = MaterialTheme.typography.titleMedium, textAlign = TextAlign.Center)
            Text(
                hint,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
fun WalletRow(wallet: WalletEntry, state: FinanceState, index: Int, count: Int, onClick: () -> Unit, modifier: Modifier = Modifier) {
    SegmentedListItem(
        onClick = onClick,
        shapes = groupShapes(index, count),
        modifier = modifier,
        colors = groupColors(),
        leadingContent = {
            ShapeBadge(
                icon = walletIcon(wallet.type),
                container = MaterialTheme.colorScheme.secondaryContainer,
                content = MaterialTheme.colorScheme.onSecondaryContainer,
                shape = MaterialShapes.Cookie9Sided.toShape(),
            )
        },
        supportingContent = { Text(walletTypeLabel(wallet.type)) },
        trailingContent = {
            Text(
                money(state, wallet.balance),
                style = MaterialTheme.typography.titleMedium.money(),
                color = MaterialTheme.colorScheme.onSurface,
            )
        },
    ) {
        Text(wallet.name, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}

@Composable
fun BillRow(
    sub: SubscriptionEntry,
    state: FinanceState,
    index: Int,
    count: Int,
    onClick: () -> Unit,
    onPay: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val completed = sub.status == "completed"
    val total = sub.totalCycles
    val moneyStyle = MaterialTheme.typography.bodyMedium.money()
    SegmentedListItem(
        onClick = onClick,
        shapes = groupShapes(index, count),
        modifier = modifier.alpha(if (completed) 0.6f else 1f),
        colors = groupColors(),
        leadingContent = {
            ShapeBadge(
                icon = if (sub.isInstallment) Icons.Rounded.EventRepeat else Icons.AutoMirrored.Rounded.ReceiptLong,
                container = MaterialTheme.colorScheme.tertiaryContainer,
                content = MaterialTheme.colorScheme.onTertiaryContainer,
                shape = MaterialShapes.Cookie4Sided.toShape(),
            )
        },
        supportingContent = {
            Column {
                Text(
                    buildAnnotatedString {
                        withStyle(SpanStyle(fontFamily = moneyStyle.fontFamily, fontFeatureSettings = moneyStyle.fontFeatureSettings)) {
                            append(money(state, sub.cost))
                        }
                        append("\n")
                        append(
                            if (sub.isInstallment && total != null) "Cicilan ${sub.paidCycles} dari $total · tanggal ${sub.dueDay}"
                            else "Tiap tanggal ${sub.dueDay}"
                        )
                    },
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                )
                if (sub.isInstallment && total != null && total > 0) {
                    Spacer(Modifier.height(6.dp))
                    LinearProgressIndicator(
                        progress = { sub.paidCycles.toFloat() / total },
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }
        },
        trailingContent = {
            when {
                completed -> Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Rounded.CheckCircle,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(18.dp),
                    )
                    Spacer(Modifier.width(4.dp))
                    Text("Lunas", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.primary)
                }
                isPaidThisMonth(sub) -> AssistChip(
                    onClick = onClick,
                    label = { Text("Sudah dibayar") },
                    leadingIcon = {
                        Icon(Icons.Rounded.Check, contentDescription = null, modifier = Modifier.size(AssistChipDefaults.IconSize))
                    },
                )
                else -> FilledTonalButton(onClick = onPay, shapes = ButtonDefaults.shapes()) { Text("Bayar") }
            }
        },
    ) {
        Text(sub.title, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}

@Composable
fun TransactionRow(
    tx: TransactionEntry,
    state: FinanceState,
    index: Int,
    count: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = MaterialTheme.colorScheme
    val category = state.categories.firstOrNull { it.id == tx.categoryId }?.name ?: "Tanpa kategori"
    val (icon, container, content) = when (tx.type) {
        "income" -> Triple(Icons.Rounded.ArrowDownward, colors.primaryContainer, colors.onPrimaryContainer)
        "transfer" -> Triple(Icons.Rounded.SwapHoriz, colors.secondaryContainer, colors.onSecondaryContainer)
        else -> Triple(Icons.Rounded.ArrowUpward, colors.surfaceContainerHighest, colors.onSurface)
    }
    val (sign, amountColor) = when (tx.type) {
        "income" -> "+" to colors.primary
        "transfer" -> "" to colors.onSurfaceVariant
        else -> "−" to colors.onSurface
    }
    // the wallet only helps tell rows apart once there is more than one
    val supporting = when {
        tx.type == "transfer" -> "${walletName(state, tx.walletId)} → ${walletName(state, tx.destinationWalletId)}"
        state.wallets.size > 1 -> "$category · ${walletName(state, tx.walletId)}"
        else -> category
    }
    SegmentedListItem(
        onClick = onClick,
        shapes = groupShapes(index, count),
        modifier = modifier,
        colors = groupColors(),
        leadingContent = { ShapeBadge(icon = icon, container = container, content = content, shape = CircleShape) },
        supportingContent = { Text(supporting, maxLines = 1, overflow = TextOverflow.Ellipsis) },
        trailingContent = {
            Text(money(state, tx.amount, sign), style = MaterialTheme.typography.titleSmall.money(), color = amountColor)
        },
    ) {
        Text(tx.notes?.takeIf { it.isNotBlank() } ?: category, maxLines = 1, overflow = TextOverflow.Ellipsis)
    }
}
