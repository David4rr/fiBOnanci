package com.fibonanci.app.ui.subscription

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Check
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.ui.theme.PlusJakartaSans
import java.time.LocalDate

object SubscriptionCardBadges {
    @Composable
    fun buildStatusBadge(
        isPaid: Boolean,
        dueDay: Int,
        config: SubscriptionCardThemeConfig,
        isInstallment: Boolean = false,
        totalCycles: Int? = null,
        paidCycles: Int = 0,
        isCompleted: Boolean = false,
    ) {
        val today = LocalDate.now().dayOfMonth
        val isDarkBg = config.backgroundColor.luminance() < 0.35f
        val cyclesDone = isInstallment && totalCycles != null && paidCycles >= totalCycles
        val isPaidState = isCompleted || isPaid || cyclesDone

        val badgeBg: Color
        val borderColor: Color
        val accentColor: Color
        val textColor: Color
        val statusText: String

        if (isCompleted || cyclesDone) {
            badgeBg = Color(0xFF0E1015).copy(alpha = if (isDarkBg) 0.82f else 0.92f)
            borderColor = Color(0xFFD4F442).copy(alpha = if (isDarkBg) 0.38f else 0.25f)
            accentColor = Color(0xFFD4F442)
            textColor = Color(0xFFF8FAFC)
            statusText = "CICILAN LUNAS ($paidCycles/${totalCycles ?: paidCycles})"
        } else if (isInstallment && isPaid) {
            badgeBg = Color(0xFF0E1015).copy(alpha = if (isDarkBg) 0.82f else 0.92f)
            borderColor = Color(0xFFD4F442).copy(alpha = if (isDarkBg) 0.38f else 0.25f)
            accentColor = Color(0xFFD4F442)
            textColor = Color(0xFFF8FAFC)
            statusText = "CICILAN $paidCycles/${totalCycles ?: "?"} • LUNAS"
        } else if (isPaid) {
            badgeBg = Color(0xFF0E1015).copy(alpha = if (isDarkBg) 0.82f else 0.92f)
            borderColor = Color(0xFFD4F442).copy(alpha = if (isDarkBg) 0.38f else 0.25f)
            accentColor = Color(0xFFD4F442)
            textColor = Color(0xFFF8FAFC)
            statusText = "LUNAS BULAN INI"
        } else {
            val currentStep = (paidCycles + 1).coerceIn(1, totalCycles ?: 99)
            val prefix = if (isInstallment) "CICILAN $currentStep/$totalCycles • " else "JATUH TEMPO "
            if (today == dueDay) {
                badgeBg = Color(0xFF141115).copy(alpha = 0.90f)
                borderColor = Color(0xFFFF6B6B).copy(alpha = 0.45f)
                accentColor = Color(0xFFFF6B6B)
                textColor = Color(0xFFFFF1F2)
                statusText = "${prefix}HARI INI"
            } else if (today < dueDay && (dueDay - today) <= 3) {
                val diff = dueDay - today
                badgeBg = Color(0xFF121318).copy(alpha = 0.88f)
                borderColor = Color(0xFFFBBF24).copy(alpha = 0.38f)
                accentColor = Color(0xFFFBBF24)
                textColor = Color(0xFFFEF3C7)
                statusText = "${prefix}H-$diff"
            } else {
                badgeBg = if (isDarkBg) Color.White.copy(alpha = 0.10f) else Color.Black.copy(alpha = 0.08f)
                borderColor = config.textColor.copy(alpha = 0.14f)
                accentColor = config.textColor.copy(alpha = 0.70f)
                textColor = config.textColor
                statusText = "${prefix}TGL $dueDay"
            }
        }

        val shape = RoundedCornerShape(999.dp)
        Row(
            modifier = Modifier
                .background(badgeBg, shape)
                .border(0.9.dp, borderColor, shape)
                .padding(start = if (isPaidState) 5.dp else 9.dp, top = 4.dp, end = 10.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (isPaidState) {
                Box(
                    modifier = Modifier.size(15.dp).background(accentColor, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.Rounded.Check, contentDescription = null, modifier = Modifier.size(10.5.dp), tint = Color(0xFF0C0D11))
                }
            } else {
                Box(modifier = Modifier.size(6.dp).background(accentColor, CircleShape))
            }
            Spacer(Modifier.width(6.dp))
            Text(
                statusText,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 9.5.sp,
                    fontWeight = FontWeight.W800,
                    letterSpacing = 0.35.sp,
                    color = textColor,
                ),
            )
        }
    }

    @Composable
    fun buildNetworkBadge(config: SubscriptionCardThemeConfig) {
        Box(
            modifier = Modifier
                .background(config.textColor, RoundedCornerShape(7.dp))
                .padding(horizontal = 8.dp, vertical = 3.5.dp),
        ) {
            Text(
                config.networkBadgeText,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 9.5.sp,
                    fontWeight = FontWeight.W900,
                    color = config.backgroundColor,
                    letterSpacing = 0.6.sp,
                ),
            )
        }
    }

    @Composable
    fun buildInstallmentProgress(
        isPaidThisMonth: Boolean,
        subscription: SubscriptionEntry,
        config: SubscriptionCardThemeConfig,
    ) {
        val totalCycles = subscription.totalCycles ?: 1
        val paidCycles = subscription.paidCycles
        val isCompleted = subscription.status == "completed" || paidCycles >= totalCycles
        val remainingCycles = (totalCycles - paidCycles).coerceIn(0, totalCycles)
        val progress = (paidCycles.toFloat() / totalCycles).coerceIn(0f, 1f)

        Column {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                buildStatusBadge(
                    isPaidThisMonth,
                    subscription.dueDay,
                    config,
                    isInstallment = true,
                    totalCycles = totalCycles,
                    paidCycles = paidCycles,
                    isCompleted = isCompleted,
                )
                Box(
                    modifier = Modifier
                        .background(config.textColor.copy(alpha = 0.12f), RoundedCornerShape(6.dp))
                        .padding(horizontal = 7.dp, vertical = 3.dp),
                ) {
                    Text(
                        if (isCompleted) "LUNAS" else "Sisa $remainingCycles bln",
                        style = TextStyle(
                            fontFamily = PlusJakartaSans,
                            fontSize = 9.5.sp,
                            fontWeight = FontWeight.W800,
                            letterSpacing = 0.5.sp,
                            color = config.textColor,
                        ),
                    )
                }
            }
            Spacer(Modifier.height(7.dp))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(3.dp))
                    .background(config.textColor.copy(alpha = 0.16f)),
            ) {
                Box(Modifier.fillMaxWidth(progress).height(4.dp).background(config.textColor))
            }
        }
    }

    @Composable
    fun buildBillingSchedule(
        isPaidThisMonth: Boolean,
        subscription: SubscriptionEntry,
        config: SubscriptionCardThemeConfig,
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            buildStatusBadge(isPaidThisMonth, subscription.dueDay, config, isInstallment = false)
            Box(
                modifier = Modifier
                    .background(config.textColor.copy(alpha = 0.12f), RoundedCornerShape(6.dp))
                    .padding(horizontal = 8.dp, vertical = 3.5.dp),
            ) {
                Text(
                    if (subscription.billingCycle == "monthly") "BULANAN" else "TAHUNAN",
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 9.5.sp,
                        fontWeight = FontWeight.W800,
                        letterSpacing = 0.6.sp,
                        color = config.textColor,
                    ),
                )
            }
        }
    }
}
