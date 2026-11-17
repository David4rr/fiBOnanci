package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.toEpochMillis
import com.fibonanci.app.core.toLocalDate
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.time.LocalDate
import java.time.YearMonth
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

internal val idMonthYearFormat: DateTimeFormatter = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.forLanguageTag("id-ID"))

// segmented toggle and mandatory deadline / tenor selector for installment plans.
object SubscriptionInstallmentSelector {
    val tenorPresets = listOf(3, 6, 12)

    fun calculateDeadlineDate(
        dueDay: Int,
        totalCycles: Int,
        referenceDate: Long? = null,
    ): Long {
        val now = referenceDate?.toLocalDate() ?: LocalDate.now()
        val startMonth = if (now.dayOfMonth <= dueDay) now.monthValue else now.monthValue + 1
        val totalMonths = startMonth + totalCycles - 1
        val targetYear = now.year + Math.floorDiv(totalMonths - 1, 12)
        val targetMonth = Math.floorMod(totalMonths - 1, 12) + 1
        val maxDays = YearMonth.of(targetYear, targetMonth).lengthOfMonth()
        val clampedDay = dueDay.coerceIn(1, maxDays)
        return LocalDateTime.of(targetYear, targetMonth, clampedDay, 23, 59, 59).toEpochMillis()
    }
}

@Composable
fun SubscriptionInstallmentSelector(
    isInstallment: Boolean,
    totalCycles: Int,
    dueDay: Int,
    onToggleInstallment: (Boolean) -> Unit,
    onCyclesChanged: (Int) -> Unit,
) {
    var isCustom by remember { mutableStateOf(totalCycles !in SubscriptionInstallmentSelector.tenorPresets) }
    var customText by remember { mutableStateOf(totalCycles.toString()) }

    // mirrors didUpdateWidget: sync custom field when cycles change from outside
    LaunchedEffect(totalCycles) {
        if (totalCycles !in SubscriptionInstallmentSelector.tenorPresets) isCustom = true
        if (customText != totalCycles.toString()) customText = totalCycles.toString()
    }

    fun updateCycles(value: Int) {
        val clamped = value.coerceIn(1, 120)
        customText = clamped.toString()
        onCyclesChanged(clamped)
    }

    val deadline = SubscriptionInstallmentSelector.calculateDeadlineDate(dueDay = dueDay, totalCycles = totalCycles)
    val deadlineStr = deadline.toLocalDate().format(idMonthYearFormat)

    Column {
        SubscriptionTypeToggle(isInstallment = isInstallment, onToggleInstallment = onToggleInstallment)
        if (isInstallment) {
            Spacer(Modifier.height(14.dp))
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "TENGGAT WAKTU CICILAN (WAJIB)",
                    modifier = Modifier.weight(1f),
                    style = AppTypography.badgeLabel.copy(color = AppColors.neoCoral, letterSpacing = 0.8.sp),
                    overflow = TextOverflow.Ellipsis,
                    maxLines = 1,
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    "Selesai $deadlineStr",
                    modifier = Modifier
                        .background(AppColors.neoCoral.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
                        .padding(horizontal = 8.dp, vertical = 3.dp),
                    style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.W700, color = AppColors.neoCoral),
                )
            }
            Spacer(Modifier.height(8.dp))
            Row(modifier = Modifier.fillMaxWidth()) {
                for (preset in SubscriptionInstallmentSelector.tenorPresets) {
                    SubscriptionTenorPresetButton(
                        label = "${preset}x",
                        isSelected = !isCustom && totalCycles == preset,
                        onTap = {
                            isCustom = false
                            updateCycles(preset)
                        },
                        modifier = Modifier.weight(1f),
                    )
                    Spacer(Modifier.width(6.dp))
                }
                SubscriptionTenorPresetButton(
                    label = "Custom",
                    isSelected = isCustom,
                    onTap = { isCustom = true },
                    modifier = Modifier.weight(1f),
                )
            }
            if (isCustom) {
                Spacer(Modifier.height(10.dp))
                SubscriptionCustomTenorRow(
                    value = customText,
                    onValueChange = { customText = it },
                    totalCycles = totalCycles,
                    onChanged = onCyclesChanged,
                )
            }
        }
    }
}
