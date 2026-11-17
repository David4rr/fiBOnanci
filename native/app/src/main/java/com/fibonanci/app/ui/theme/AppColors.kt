package com.fibonanci.app.ui.theme

import androidx.compose.ui.graphics.Color

object AppColors {
    // canvas & surfaces (deep obsidian matte)
    val canvasBg = Color(0xFF0C0D11)
    val canvasCardSurface = Color(0xFF17181F)
    val canvasInputSearch = Color(0xFF1C1E26)
    val canvasBorder = Color(0xFF2A2C38)
    val canvasBorderSubtle = Color(0xFF1F2230)
    val carbonBlack = Color(0xFF0C0A00)

    // vibrant neo-pastel palette (card & folder accents)
    val neoChartreuse = Color(0xFFD4F442) // safe-to-spend & rekening/dompet accent
    val neoMint = Color(0xFF7DF24E) // total real balance
    val neoCoral = Color(0xFFFF7052) // pending monthly bills
    val neoCyan = Color(0xFF26D9D9) // daily budget allowance
    val neoPurple = Color(0xFFA855F7) // e-wallet / ovo

    // typography & contrast tokens
    val textWhite = Color(0xFFFFFFFF)
    val textMuted = Color(0xFF8E92A0)
    val textSubtle = Color(0xFF525666)

    val textDarkPrimary = Color(0xFF0A0B0E)
    val textDarkSecondary = Color(0xFF2C303E)

    val cardIconBadgeBg = Color(0x1F000000) // 12% black overlay

    // financial status colors
    val statusComfortable = neoChartreuse
    val statusCaution = Color(0xFFF59E0B)
    val statusDeficit = Color(0xFFEF4444)

    // same as dart: '#' becomes '0xFF' and the result goes through int.tryParse
    fun fromHex(hex: String): Color {
        val raw = hex.replace("#", "0xFF")
        val parsed = parseDartInt(raw) ?: 0xFFD4F442L
        return Color((parsed and 0xFFFFFFFFL).toInt())
    }

    // mirrors dart int.tryParse: optional sign, decimal or 0x-prefixed hex
    private fun parseDartInt(source: String): Long? {
        val s = source.trim()
        val negative = s.startsWith("-")
        val unsigned = if (s.startsWith("-") || s.startsWith("+")) s.substring(1) else s
        val value = if (unsigned.startsWith("0x") || unsigned.startsWith("0X")) {
            unsigned.substring(2).toULongOrNull(16)?.toLong()
        } else {
            unsigned.toLongOrNull()
        } ?: return null
        return if (negative) -value else value
    }
}
