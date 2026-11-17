package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

// wallets is kept from the dart signature; the sheet reads live state like the dart BlocBuilder.
fun showSafeToSpendModal(host: ModalHost, wallets: List<WalletEntry> = emptyList()) {
    host.show(ModalKind.Sheet) { dismiss ->
        val state by LocalFinance.current.state.collectAsStateWithLifecycle()
        val metrics = state.metrics
        val isAll = state.safeToSpendWalletIds.isNullOrEmpty()
        val currency = state.profile.currency
        fun fmt(x: Double) = AppCurrency.format(x, currency)

        CardSurfaceSheet {
            ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
            ModalHeader(
                title = "Smart Safe-to-Spend",
                subtitle = "Status: ${metrics.statusLabel}",
                subtitleStyle = TextStyle(fontFamily = PlusJakartaSans, color = metrics.statusColor, fontWeight = FontWeight.Bold, fontSize = 12.sp),
                onClose = dismiss,
            )
            Spacer(Modifier.height(18.dp))
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
                    .padding(16.dp),
            ) {
                buildCalcRow(
                    if (isAll) "Total Saldo Riil" else "Saldo Rekening Terpilih",
                    "+${fmt(metrics.totalRealBalance)}",
                    AppColors.neoChartreuse,
                )
                CalcDivider()
                buildCalcRow(
                    if (isAll) "Sisa Tagihan Bulan Ini" else "Tagihan Terkait Terpilih",
                    "-${fmt(metrics.pendingBills)}",
                    AppColors.neoCoral,
                )
                CalcDivider(height = 16.dp)
                buildCalcRow("Sisa Aman Bulan Ini", fmt(metrics.safeToSpendMonthly), metrics.statusColor, isBold = true)
                Spacer(Modifier.height(8.dp))
                buildCalcRow(
                    "Alokasi Harian (${metrics.daysRemainingInMonth} hr)",
                    "${fmt(metrics.safeToSpendDaily)} / hr",
                    AppColors.neoCyan,
                )
            }
            Spacer(Modifier.height(14.dp))
            Text(
                if (isAll) {
                    "Dihitung dari seluruh rekening Anda. Uang ini aman dibelanjakan tanpa khawatir tagihan bulanan gagal bayar."
                } else {
                    "Dihitung hanya dari rekening operasional (${metrics.selectedWalletsCount} rekening). Tagihan dan saldo rekening tabungan lain tidak dicampur."
                },
                style = AppTypography.listSubtitle,
            )
            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Tune, null, tint = AppColors.textMuted, modifier = Modifier.size(12.dp))
                Spacer(Modifier.width(6.dp))
                Text(
                    "Pilihan rekening operasional dapat diatur di Pengaturan > Siklus Anggaran & Safe-to-Spend.",
                    style = AppTypography.listSubtitle.copy(color = AppColors.textMuted, fontSize = 11.sp),
                    modifier = Modifier.weight(1f),
                )
            }
            Spacer(Modifier.height(20.dp))
        }
    }
}
