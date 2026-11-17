package com.fibonanci.app.ui.wallet

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.WalletEntry

object WalletCardAtmComponents {
    fun formatAccountNumber(wallet: WalletEntry): String {
        val num = wallet.accountNumber?.trim()
        if (num.isNullOrEmpty()) return "-"
        return num
    }

    @Composable
    fun buildChip(textColor: Color, isDark: Boolean) {
        val chipBaseColor = if (isDark) Color(0xFFD4AF37).copy(alpha = 0.22f) else textColor.copy(alpha = 0.12f)
        val chipBorderColor = if (isDark) Color(0xFFFFDF73).copy(alpha = 0.45f) else textColor.copy(alpha = 0.32f)
        val circuitColor = if (isDark) Color(0xFFFFDF73).copy(alpha = 0.35f) else textColor.copy(alpha = 0.24f)

        Box(
            Modifier
                .size(36.dp, 27.dp)
                .background(chipBaseColor, RoundedCornerShape(6.dp))
                .border(0.9.dp, chipBorderColor, RoundedCornerShape(6.dp)),
            contentAlignment = Alignment.Center,
        ) {
            Box(Modifier.size(22.dp, 16.dp).border(0.7.dp, circuitColor, RoundedCornerShape(3.dp)))
            Box(Modifier.size(0.8.dp, 16.dp).background(circuitColor))
            Box(Modifier.size(22.dp, 0.8.dp).background(circuitColor))
        }
    }

    @Composable
    fun buildContactlessIcon(color: Color) {
        val painter = ContactlessPainter(color = color.copy(alpha = 0.85f))
        Canvas(Modifier.size(16.dp, 12.dp)) { with(painter) { paint() } }
    }
}
