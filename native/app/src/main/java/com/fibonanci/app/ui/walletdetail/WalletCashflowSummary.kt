package com.fibonanci.app.ui.walletdetail

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.ui.common.PeekableBalanceText
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

// compact minimalist monthly income & expense summary strip
@Composable
fun WalletCashflowSummary(
    monthlyIncome: Double,
    monthlyExpense: Double,
    fmt: (Double) -> String,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier, horizontalAlignment = Alignment.End) {
        CompactFlowRow(label = "Masuk", amount = "+${fmt(monthlyIncome)}", color = AppColors.neoMint)
        Spacer(Modifier.height(5.dp))
        CompactFlowRow(label = "Keluar", amount = "-${fmt(monthlyExpense)}", color = AppColors.neoCoral)
    }
}

@Composable
private fun CompactFlowRow(label: String, amount: String, color: Color) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Start) {
        Spacer(Modifier.size(6.dp).background(color, CircleShape))
        Spacer(Modifier.width(6.dp))
        Text(
            label,
            style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 10.5.sp, fontWeight = FontWeight.W500, color = AppColors.textMuted),
        )
        Spacer(Modifier.width(8.dp))
        PeekableBalanceText(
            text = amount,
            iconSize = 12.dp,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 11.5.sp,
                fontWeight = FontWeight.W700,
                color = color,
                fontFeatureSettings = "tnum",
            ),
            modifier = Modifier.weight(1f, fill = false),
        )
    }
}
