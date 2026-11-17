package com.fibonanci.app.ui.common

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

/** inner panel content for the expandable search filter dropdown. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ExpandableSearchFilterPanel(
    headerTitle: String = "Filter Transaksi",
    primaryFilterTitle: String = "TIPE TRANSAKSI",
    primaryFilterChoices: List<FilterChoice> = kDefaultTransactionTypeChoices,
    tempType: String,
    tempWalletId: String?,
    wallets: List<WalletEntry>,
    showWalletFilter: Boolean,
    hasPendingChange: Boolean,
    onSelectType: (String) -> Unit,
    onSelectWallet: (String?) -> Unit,
    onReset: () -> Unit,
    onApply: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val sectionStyle = AppTypography.badgeLabel.copy(color = AppColors.textMuted, fontSize = 10.sp)

    Column(modifier.fillMaxWidth().padding(16.dp)) {
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(headerTitle, style = AppTypography.listTitle.copy(fontSize = 13.5.sp, fontWeight = FontWeight.W700))
            if (hasPendingChange) {
                Text(
                    "Reset",
                    style = AppTypography.listSubtitle.copy(
                        color = AppColors.neoChartreuse,
                        fontWeight = FontWeight.W600,
                        fontSize = 12.sp,
                    ),
                    modifier = Modifier.clickable(interactionSource = null, indication = null, onClick = onReset),
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        Text(primaryFilterTitle, style = sectionStyle)
        Spacer(Modifier.height(8.dp))
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            primaryFilterChoices.forEach { choice ->
                AppChoiceChip(
                    label = choice.label,
                    selected = tempType == choice.value,
                    onTap = { onSelectType(choice.value) },
                    borderRadius = 10.dp,
                )
            }
        }
        if (showWalletFilter && wallets.isNotEmpty()) {
            Spacer(Modifier.height(14.dp))
            Text("REKENING", style = sectionStyle)
            Spacer(Modifier.height(8.dp))
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                AppChoiceChip(
                    label = "Semua Rekening",
                    selected = tempWalletId == null,
                    onTap = { onSelectWallet(null) },
                    borderRadius = 10.dp,
                )
                wallets.forEach { w ->
                    AppChoiceChip(
                        label = w.name,
                        selected = tempWalletId == w.id,
                        onTap = { onSelectWallet(w.id) },
                        borderRadius = 10.dp,
                    )
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        PrimaryActionButton(
            text = "Terapkan Filter",
            height = 40.dp,
            borderRadius = 10.dp,
            onPressed = onApply,
        )
    }
}
