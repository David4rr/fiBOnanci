package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalance
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material.icons.rounded.CalendarToday
import androidx.compose.material.icons.rounded.EventAvailable
import androidx.compose.material.icons.rounded.PendingActions
import androidx.compose.material.icons.rounded.Repeat
import androidx.compose.material.icons.rounded.Sync
import androidx.compose.material.icons.rounded.Timelapse
import androidx.compose.material.icons.rounded.Verified
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

// specification details card for subscription or installment plan.
@Composable
fun SubscriptionDetailSpecsCard(
    subscription: SubscriptionEntry,
    wallet: WalletEntry,
    currencyFormatter: (Double) -> String,
) {
    val isPaidThisMonth = subscription.isPaidThisMonth()
    val isInstallment = subscription.isInstallment
    val totalCycles = subscription.totalCycles ?: 0
    val paidCycles = subscription.paidCycles
    val isCompleted = subscription.status == "completed" || (isInstallment && totalCycles > 0 && paidCycles >= totalCycles)
    val remainingCycles = (totalCycles - paidCycles).coerceIn(0, totalCycles)
    val remainingCost = subscription.cost * remainingCycles

    val shape = RoundedCornerShape(22.dp)
    Column(
        modifier = Modifier
            .padding(horizontal = 20.dp)
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, shape)
            .border(1.dp, AppColors.canvasBorder, shape)
            .padding(18.dp),
    ) {
        SpecRow("Rekening Pembayaran", wallet.name, Icons.Outlined.AccountBalanceWallet)
        SpecDivider()
        SpecRow("Saldo Rekening Saat Ini", currencyFormatter(wallet.balance), Icons.Outlined.AccountBalance)
        SpecDivider()
        SpecRow("Metode Pembayaran", if (subscription.autoDeduct) "Auto-Deduct Aktif" else "Manual Transfer / QRIS", Icons.Rounded.Sync)
        SpecDivider()
        SpecRow(
            "Status Periode Ini",
            if (isCompleted) "Cicilan Selesai" else if (isPaidThisMonth) "Sudah Lunas" else "Belum Dibayar",
            if (isPaidThisMonth || isCompleted) Icons.Rounded.Verified else Icons.Rounded.PendingActions,
            valueColor = if (isPaidThisMonth || isCompleted) AppColors.neoMint else AppColors.neoCoral,
        )
        if (isInstallment) {
            SpecDivider()
            SpecRow(
                "Rencana Cicilan",
                "$paidCycles dari $totalCycles bulan lunas",
                Icons.Rounded.Timelapse,
                valueColor = if (isCompleted) AppColors.neoMint else AppColors.neoCoral,
            )
            Spacer(Modifier.height(10.dp))
            ProgressBar(paidCycles = paidCycles, totalCycles = totalCycles)
            if (!isCompleted) {
                SpecDivider()
                SpecRow("Sisa Tagihan Pokok", currencyFormatter(remainingCost), Icons.Outlined.Payments, valueColor = AppColors.neoCoral)
            }
            subscription.deadlineDate?.let { deadline ->
                SpecDivider()
                SpecRow("Tenggat Selesai", deadline.toLocalDate().format(idMonthYearFormat), Icons.Rounded.EventAvailable)
            }
        } else {
            SpecDivider()
            SpecRow("Siklus Tagihan", if (subscription.billingCycle == "monthly") "Bulanan" else "Tahunan", Icons.Rounded.Repeat)
            SpecDivider()
            SpecRow("Jatuh Tempo", "Setiap tanggal ${subscription.dueDay}", Icons.Rounded.CalendarToday)
        }
    }
}

// flutter Divider(height: 20) == 1px line centered in 20 of vertical space
@Composable
private fun SpecDivider() {
    HorizontalDivider(modifier = Modifier.padding(vertical = 9.5.dp), thickness = 1.dp, color = AppColors.canvasBorder)
}

@Composable
private fun ProgressBar(paidCycles: Int, totalCycles: Int) {
    val progress = if (totalCycles > 0) (paidCycles.toFloat() / totalCycles).coerceIn(0f, 1f) else 0f
    Column {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp)
                .clip(RoundedCornerShape(6.dp))
                .background(AppColors.canvasBg),
        ) {
            Box(
                Modifier
                    .fillMaxWidth(progress)
                    .height(8.dp)
                    .background(if (progress >= 1f) AppColors.neoMint else AppColors.neoChartreuse),
            )
        }
        Spacer(Modifier.height(6.dp))
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text("Progress Pembayaran", style = AppTypography.listSubtitle.copy(fontSize = 11.sp))
            Text("${(progress * 100).toInt()}%", style = AppTypography.listTitle.copy(fontSize = 11.sp, fontWeight = FontWeight.W700))
        }
    }
}

@Composable
private fun SpecRow(label: String, value: String, icon: ImageVector, valueColor: Color? = null) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(16.dp), tint = AppColors.textMuted)
        Spacer(Modifier.width(10.dp))
        Text(label, style = AppTypography.listSubtitle)
        Spacer(Modifier.width(8.dp))
        Text(
            value,
            modifier = Modifier.weight(1f),
            textAlign = TextAlign.End,
            style = AppTypography.listTitle.copy(color = valueColor ?: AppColors.textWhite, fontSize = 13.sp, fontWeight = FontWeight.W600),
        )
    }
}
