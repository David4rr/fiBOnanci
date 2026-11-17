package com.fibonanci.app.ui.theme

import androidx.compose.ui.text.ExperimentalTextApi
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontVariation
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import com.fibonanci.app.R

// variable font: one instance per weight axis value
@OptIn(ExperimentalTextApi::class)
val PlusJakartaSans: FontFamily = FontFamily(
    (200..800 step 100).map { w ->
        Font(
            resId = R.font.plus_jakarta_sans,
            weight = FontWeight(w),
            variationSettings = FontVariation.Settings(FontVariation.weight(w)),
        )
    },
)

// tabular figures, matches dart FontFeature.tabularFigures()
const val TABULAR_FIGURES = "tnum"

object AppTypography {
    val heroGreeting = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 26.sp,
        fontWeight = FontWeight.W700,
        color = AppColors.textWhite,
        letterSpacing = (-0.5).sp,
        lineHeight = 1.2.em,
    )

    val modalTitle = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 28.sp,
        fontWeight = FontWeight.W800,
        color = AppColors.textWhite,
        lineHeight = 1.06.em,
        letterSpacing = (-0.8).sp,
    )

    val modalSubtitle = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 12.sp,
        fontWeight = FontWeight.W500,
        color = AppColors.textMuted,
    )

    val cardMetricValue = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 22.sp,
        fontWeight = FontWeight.W800,
        color = AppColors.textDarkPrimary,
        letterSpacing = (-0.5).sp,
        fontFeatureSettings = TABULAR_FIGURES,
    )

    val cardMetricLabel = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 12.sp,
        fontWeight = FontWeight.W600,
        color = AppColors.textDarkSecondary,
        letterSpacing = 0.1.sp,
    )

    val sectionTitle = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 18.sp,
        fontWeight = FontWeight.W700,
        color = AppColors.textWhite,
        letterSpacing = (-0.3).sp,
    )

    val listTitle = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 15.sp,
        fontWeight = FontWeight.W600,
        color = AppColors.textWhite,
    )

    val listSubtitle = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 12.sp,
        fontWeight = FontWeight.W400,
        color = AppColors.textMuted,
    )

    val listAmount = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 16.sp,
        fontWeight = FontWeight.W700,
        color = AppColors.textWhite,
        letterSpacing = (-0.2).sp,
        fontFeatureSettings = TABULAR_FIGURES,
    )

    val badgeLabel = TextStyle(
        fontFamily = PlusJakartaSans,
        fontSize = 10.sp,
        fontWeight = FontWeight.W700,
        letterSpacing = 0.6.sp,
    )
}
