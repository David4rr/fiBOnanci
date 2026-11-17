package com.fibonanci.app.ui.report

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.domain.FinancialReportData
import com.fibonanci.app.domain.WalletReportItem
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

private val sectionLabelStyle = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.sp, fontWeight = FontWeight.W600, color = AppColors.textMuted, letterSpacing = 0.6.sp)

@Composable
fun FinancialReportBreakdownCards(data: FinancialReportData) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    fun fmt(x: Double) = AppCurrency.format(x, currency)
    val wallets = data.walletBreakdown

    Column {
        ReportCard {
            Text("POSISI ASET & KEWAJIBAN", style = sectionLabelStyle)
            Spacer(Modifier.height(12.dp))
            AssetRow("Total Kekayaan Bersih", fmt(data.totalNetWorth), AppColors.textWhite, isBold = true)
            HorizontalDivider(Modifier.padding(vertical = 10.dp), thickness = Dp.Hairline, color = Color.White.copy(alpha = 0.06f))
            AssetRow("Saldo Rekening Aktif", fmt(data.totalWalletBalance), AppColors.textWhite)
            Spacer(Modifier.height(8.dp))
            AssetRow("Dana Kantong Tabungan", fmt(data.totalPocketBalance), AppColors.textMuted)
            Spacer(Modifier.height(8.dp))
            AssetRow("Komitmen Tagihan Bulanan", fmt(data.monthlyCommittedBills), AppColors.neoCoral)
        }
        Spacer(Modifier.height(14.dp))
        ReportCard {
            Text("AKTIVITAS PER REKENING", style = sectionLabelStyle)
            Spacer(Modifier.height(8.dp))
            if (wallets.isEmpty()) {
                Box(Modifier.fillMaxWidth().padding(vertical = 12.dp), contentAlignment = Alignment.Center) {
                    Text("Belum ada rekening aktif", style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.sp, color = AppColors.textMuted))
                }
            } else {
                for (w in wallets) WalletRow(w, fmt(w.balance), fmt(w.income), fmt(w.expense))
            }
        }
    }
}

@Composable
private fun ReportCard(content: @Composable ColumnScope.() -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(Color.White.copy(alpha = 0.03f), RoundedCornerShape(20.dp))
            .border(1.dp, Color.White.copy(alpha = 0.06f), RoundedCornerShape(20.dp))
            .padding(horizontal = 18.dp, vertical = 16.dp),
        content = content,
    )
}

@Composable
private fun AssetRow(label: String, value: String, valueColor: Color, isBold: Boolean = false) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
            label,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 12.5.sp,
                color = if (isBold) AppColors.textWhite else AppColors.textMuted,
                fontWeight = if (isBold) FontWeight.W600 else FontWeight.W400,
            ),
            modifier = Modifier.weight(1f),
        )
        Spacer(Modifier.width(8.dp))
        Text(
            value,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = if (isBold) 13.5.sp else 12.5.sp,
                fontWeight = if (isBold) FontWeight.W700 else FontWeight.W600,
                color = valueColor,
                fontFeatureSettings = "tnum",
            ),
            modifier = Modifier.weight(1f, fill = false),
        )
    }
}

@Composable
private fun WalletRow(w: WalletReportItem, balStr: String, inStr: String, outStr: String) {
    val dotColor = CategoryDonutChart.resolveSliceColor(w.colorHex, false, 1)
    Row(Modifier.padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
        Box(Modifier.size(7.dp).background(dotColor, CircleShape))
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(w.name, style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 12.5.sp, fontWeight = FontWeight.W600, color = AppColors.textWhite))
            Text(balStr, style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, color = AppColors.textMuted, fontFeatureSettings = "tnum"))
        }
        Column(horizontalAlignment = Alignment.End) {
            Text("+$inStr", style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.5.sp, fontWeight = FontWeight.W600, color = AppColors.neoMint, fontFeatureSettings = "tnum"))
            Spacer(Modifier.height(2.dp))
            Text("-$outStr", style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.5.sp, fontWeight = FontWeight.W600, color = AppColors.neoCoral, fontFeatureSettings = "tnum"))
        }
    }
}
