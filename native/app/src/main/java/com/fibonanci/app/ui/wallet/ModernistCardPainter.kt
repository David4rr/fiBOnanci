package com.fibonanci.app.ui.wallet

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope

// abstract modernist graphics behind each wallet card
class ModernistCardPainter(
    val theme: ModernistCardTheme,
    val primaryColor: Color,
    val secondaryColor: Color,
) {
    fun DrawScope.paint() {
        when (theme) {
            ModernistCardTheme.aiCloudProductivity,
            ModernistCardTheme.fitnessLifestyle -> ModernistPaintersBase.paintTerracottaDisks(this, primaryColor)
            ModernistCardTheme.audioEmerald -> ModernistPaintersBase.paintSageHatching(this, primaryColor)
            ModernistCardTheme.fiberInternet -> ModernistPaintersBase.paintPeriwinkleOvals(this, primaryColor)
            ModernistCardTheme.utilitiesLemon -> ModernistPaintersBase.paintNeonSunburst(this)
            ModernistCardTheme.recurringSmartBill -> ModernistPaintersBase.paintOatmealWaves(this, primaryColor)
            ModernistCardTheme.streamingCinematic,
            ModernistCardTheme.housingLiving -> ModernistPaintersBase.paintGeometricCurves(this, primaryColor)
            ModernistCardTheme.tokyoMidnight -> ModernistPaintersAmbient.paintTokyoMidnight(this, primaryColor, secondaryColor)
            ModernistCardTheme.solarAmber -> ModernistPaintersAmbient.paintSolarAmber(this, primaryColor, secondaryColor)
            ModernistCardTheme.arcticGlacier -> ModernistPaintersAmbient.paintArcticGlacier(this, primaryColor, secondaryColor)
            ModernistCardTheme.cyberNeon -> ModernistPaintersAmbient.paintCyberNeon(this, primaryColor, secondaryColor)
            ModernistCardTheme.matchaZen -> ModernistPaintersAmbient.paintMatchaZen(this, primaryColor, secondaryColor)
            ModernistCardTheme.terracottaSunset -> ModernistPaintersAmbient.paintTerracottaSunset(this, primaryColor, secondaryColor)
            ModernistCardTheme.monochromeStark -> ModernistPaintersGeometric.paintMonochromeStark(this, primaryColor, secondaryColor)
            ModernistCardTheme.lavenderDusk -> ModernistPaintersGeometric.paintLavenderDusk(this, primaryColor, secondaryColor)
            ModernistCardTheme.cobaltVault -> ModernistPaintersGeometric.paintCobaltVault(this, primaryColor, secondaryColor)
            ModernistCardTheme.blushPop -> ModernistPaintersGeometric.paintBlushPop(this, primaryColor, secondaryColor)
            ModernistCardTheme.nordicPine -> ModernistPaintersGeometric.paintNordicPine(this, primaryColor)
            ModernistCardTheme.copperPatina -> ModernistPaintersGeometric.paintCopperPatina(this, primaryColor, secondaryColor)
        }
    }
}
