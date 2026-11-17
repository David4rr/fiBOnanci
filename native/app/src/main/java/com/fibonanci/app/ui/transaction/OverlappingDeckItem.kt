package com.fibonanci.app.ui.transaction

import androidx.compose.animation.core.EaseOutCubic
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.PlusJakartaSans
import kotlin.math.abs

private val ink = Color(0xFF0C0D11)

// individual pastel expense card item matching the swiss-editorial reference
@Composable
fun OverlappingDeckItem(
    title: String,
    category: String,
    amount: Double,
    categoryColor: Color,
    iconData: ImageVector,
    subtitle: String? = null,
    isExpense: Boolean = true,
    isExpanded: Boolean = false,
    transactionDate: Long? = null,
    weeklySpending: List<Double>? = null,
    onTap: (() -> Unit)? = null,
    onManage: (() -> Unit)? = null,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val currency = state.profile.currency
    val signPrefix = if (isExpense) "-" else "+"
    val currencyFormatter: (Double) -> String = { AppCurrency.format(it, currency, signPrefix) }
    val height by animateDpAsState(if (isExpanded) 295.dp else 190.dp, tween(280, easing = EaseOutCubic), label = "deckItemHeight")
    val shape = RoundedCornerShape(26.dp)

    Box(
        Modifier
            .fillMaxWidth()
            .height(height)
            .shadow(
                if (isExpanded) 8.dp else 3.dp, shape,
                ambientColor = Color.Black.copy(alpha = if (isExpanded) 0.18f else 0.08f),
                spotColor = Color.Black.copy(alpha = if (isExpanded) 0.18f else 0.08f),
            )
            .clip(shape)
            .background(categoryColor)
            .border(
                if (isExpanded) 2.dp else 1.dp,
                if (isExpanded) ink.copy(alpha = 0.35f) else Color.Black.copy(alpha = 0.06f),
                shape,
            )
            .clickable(remember { MutableInteractionSource() }, null) { onTap?.invoke() }
            .padding(start = 18.dp, top = 14.dp, end = 18.dp, bottom = 14.dp),
    ) {
        // never-scrollable column: content past the card height is simply clipped
        Column(Modifier.fillMaxWidth().wrapContentHeight(Alignment.Top, unbounded = true)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(Modifier.size(38.dp).background(ink.copy(alpha = 0.12f), CircleShape), contentAlignment = Alignment.Center) {
                    Icon(iconData, null, Modifier.size(20.dp), tint = ink)
                }
                Spacer(Modifier.width(8.dp))
                Text(
                    currencyFormatter(abs(amount)),
                    modifier = Modifier.weight(1f),
                    textAlign = TextAlign.End,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = TextStyle(
                        fontFamily = PlusJakartaSans, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold,
                        color = ink, letterSpacing = (-0.6).sp, fontFeatureSettings = "tnum",
                    ),
                )
            }
            Spacer(Modifier.height(10.dp))
            Text(
                category.uppercase(),
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, color = ink.copy(alpha = 0.65f), letterSpacing = 0.5.sp),
            )
            Spacer(Modifier.height(2.dp))
            Text(
                title,
                style = TextStyle(fontFamily = PlusJakartaSans, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold, color = ink, letterSpacing = (-0.4).sp),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            if (isExpanded) {
                OverlappingDeckExpandedInsight(
                    category = category,
                    categoryColor = categoryColor,
                    transactionDate = transactionDate ?: nowMillis(),
                    weeklySpending = weeklySpending,
                    currencyFormatter = currencyFormatter,
                    onManage = onManage,
                    subtitle = subtitle,
                )
            }
        }
    }
}
