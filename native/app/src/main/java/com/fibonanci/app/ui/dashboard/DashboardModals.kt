package com.fibonanci.app.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
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
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.domain.SafeToSpendMetrics
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun buildCalcRow(label: String, value: String, color: Color, isBold: Boolean = false) {
    Row(
        Modifier.fillMaxWidth().padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            label,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                color = AppColors.textWhite,
                fontSize = 13.sp,
                fontWeight = if (isBold) FontWeight.Bold else FontWeight.Normal,
            ),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )
        Spacer(Modifier.width(8.dp))
        Text(
            value,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                color = color,
                fontSize = 14.sp,
                fontWeight = if (isBold) FontWeight.Bold else FontWeight.W600,
                fontFeatureSettings = "tnum",
            ),
        )
    }
}

// flutter Divider: hairline line centered in a box of `height`
@Composable
internal fun CalcDivider(color: Color = AppColors.canvasBorder, height: Dp = 16.dp) {
    HorizontalDivider(Modifier.padding(vertical = height / 2), thickness = Dp.Hairline, color = color)
}

// surface used by the dart showModalBottomSheet(backgroundColor: canvasCardSurface, top radius 28)
@Composable
internal fun CardSurfaceSheet(content: @Composable () -> Unit) {
    Column(
        Modifier
            .fillMaxWidth()
            .background(AppColors.canvasCardSurface, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
            .navigationBarsPadding()
            .padding(24.dp),
    ) { content() }
}

fun showWalletsListModal(host: ModalHost, wallets: List<WalletEntry>) {
    host.show(ModalKind.Sheet) { dismiss ->
        val state by LocalFinance.current.state.collectAsStateWithLifecycle()
        CardSurfaceSheet {
            ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
            ModalHeader(
                title = "Rincian Saldo Rekening",
                subtitle = "Ringkasan saldo riil per akun keuangan",
                onClose = dismiss,
            )
            for (w in wallets) {
                Row(Modifier.padding(vertical = 6.dp), verticalAlignment = Alignment.CenterVertically) {
                    Spacer(Modifier.size(12.dp).background(AppColors.fromHex(w.colorHex), CircleShape))
                    Spacer(Modifier.width(12.dp))
                    Text(w.name, style = AppTypography.listTitle)
                    Spacer(Modifier.weight(1f))
                    Text(AppCurrency.format(w.balance, state.profile.currency), style = AppTypography.listAmount)
                }
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

fun showDailyPaceModal(host: ModalHost, metrics: SafeToSpendMetrics) {
    host.show(ModalKind.Sheet) { dismiss ->
        val state by LocalFinance.current.state.collectAsStateWithLifecycle()
        val currency = state.profile.currency
        CardSurfaceSheet {
            ModalGrabHandle(padding = PaddingValues(bottom = 14.dp))
            ModalHeader(
                title = "Alokasi Harian (Daily Pace)",
                subtitle = "Daily burn allowance & sisa hari siklus",
                onClose = dismiss,
            )
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(AppColors.canvasInputSearch, RoundedCornerShape(16.dp))
                    .padding(16.dp),
            ) {
                buildCalcRow("Sisa Hari Bulan Ini", "${metrics.daysRemainingInMonth} Hari", AppColors.textWhite)
                CalcDivider()
                buildCalcRow(
                    "Batas Aman Belanja / Hari",
                    AppCurrency.format(metrics.safeToSpendDaily, currency),
                    AppColors.neoCyan,
                    isBold = true,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                "Menjaga belanja rata-rata harian Anda di bawah angka ini akan menjamin keuangan tetap surplus hingga akhir bulan.",
                style = AppTypography.listSubtitle,
            )
            Spacer(Modifier.height(16.dp))
        }
    }
}
