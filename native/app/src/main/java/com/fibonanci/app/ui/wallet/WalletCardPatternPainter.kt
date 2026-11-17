package com.fibonanci.app.ui.wallet

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope

// available procedural card texture patterns
enum class WalletPatternType {
    topographicContours, // organic elevation lines, swiss alpine cartography
    bauhausConcentric, // modernist overlapping arc rings & discs
    isometricCircuit, // micro-tech 45° cross-hatch & node pathways
    fluidWaveSplines, // layered flowing sine curves & liquidity waves
    angularPrismGeom, // bold angled facets, diagonal light shards
    constellationMatrix, // mathematical dot matrix with orbital constellation nodes
}

object WalletPatternHelper {
    // deterministically assigns a pattern based on wallet id string or index
    fun getPatternForWallet(walletId: String, fallbackIndex: Int? = null): WalletPatternType {
        val values = WalletPatternType.entries
        if (walletId.isNotEmpty()) {
            var hash = 0
            for (ch in walletId) {
                hash = ((hash shl 5) - hash + ch.code) and 0x7FFFFFFF
            }
            return values[hash % values.size]
        }
        return values[(fallbackIndex ?: 0) % values.size]
    }
}

// renders tactile procedural card textures
class WalletCardPatternPainter(
    val patternType: WalletPatternType,
    val primaryPatternColor: Color,
    val secondaryPatternColor: Color,
) {
    fun DrawScope.paint() {
        when (patternType) {
            WalletPatternType.topographicContours ->
                WalletPatternsOrganic.paintTopographicContours(this, primaryPatternColor, secondaryPatternColor)
            WalletPatternType.bauhausConcentric ->
                WalletPatternsOrganic.paintBauhausConcentric(this, primaryPatternColor, secondaryPatternColor)
            WalletPatternType.fluidWaveSplines ->
                WalletPatternsOrganic.paintFluidWaveSplines(this, primaryPatternColor, secondaryPatternColor)
            WalletPatternType.isometricCircuit ->
                WalletPatternsGeometric.paintIsometricCircuit(this, primaryPatternColor, secondaryPatternColor)
            WalletPatternType.angularPrismGeom ->
                WalletPatternsGeometric.paintAngularPrismGeom(this, primaryPatternColor, secondaryPatternColor)
            WalletPatternType.constellationMatrix ->
                WalletPatternsGeometric.paintConstellationMatrix(this, primaryPatternColor, secondaryPatternColor)
        }
    }
}
