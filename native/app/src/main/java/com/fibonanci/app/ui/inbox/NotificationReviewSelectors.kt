package com.fibonanci.app.ui.inbox

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.ArrowDropDown
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography
import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import kotlin.math.abs

object NotificationReviewSelectors {
    @Composable
    fun RowScope.buildTypePill(
        label: String,
        isSelected: Boolean,
        activeColor: Color,
        onTap: () -> Unit,
    ) {
        val bg by animateColorAsState(
            if (isSelected) activeColor.copy(alpha = 0.15f) else AppColors.canvasInputSearch,
            tween(180),
            label = "pillBg",
        )
        val borderColor by animateColorAsState(if (isSelected) activeColor else AppColors.canvasBorder, tween(180), label = "pillBorder")
        val borderWidth by animateDpAsState(if (isSelected) 1.5.dp else 1.dp, tween(180), label = "pillWidth")
        val shape = RoundedCornerShape(14.dp)
        Box(
            modifier = Modifier
                .weight(1f)
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onTap)
                .background(bg, shape)
                .border(borderWidth, borderColor, shape)
                .padding(vertical = 12.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                label,
                style = TextStyle(
                    color = if (isSelected) activeColor else AppColors.textMuted,
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp,
                ),
            )
        }
    }

    @Composable
    fun buildWalletDropdown(
        wallets: List<WalletEntry>,
        selectedWalletId: String?,
        onChanged: (String?) -> Unit,
    ) {
        val value = if (wallets.any { it.id == selectedWalletId }) selectedWalletId else wallets.firstOrNull()?.id
        val selected = wallets.firstOrNull { it.id == value }
        val shape = RoundedCornerShape(16.dp)
        Dropdown(
            modifier = Modifier
                .background(AppColors.canvasInputSearch, shape)
                .border(1.5.dp, AppColors.neoChartreuse.copy(alpha = 0.5f), shape),
            selected = if (selected != null) { { WalletRow(selected) } } else null,
            options = wallets.map { w -> w.id to @Composable { WalletRow(w) } },
            onChanged = onChanged,
        )
    }

    @Composable
    fun buildCategoryDropdown(
        categories: List<CategoryEntry>,
        selectedCategoryId: String?,
        onChanged: (String?) -> Unit,
    ) {
        val value = if (categories.any { it.id == selectedCategoryId }) selectedCategoryId else categories.firstOrNull()?.id
        val selected = categories.firstOrNull { it.id == value }
        val shape = RoundedCornerShape(16.dp)
        Dropdown(
            modifier = Modifier
                .background(AppColors.canvasInputSearch, shape)
                .border(1.dp, AppColors.canvasBorder, shape),
            selected = if (selected != null) { { Text(selected.name, style = AppTypography.listTitle) } } else null,
            options = categories.map { c -> c.id to @Composable { Text(c.name, style = AppTypography.listTitle) } },
            onChanged = onChanged,
        )
    }

    @Composable
    private fun WalletRow(w: WalletEntry) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(12.dp).background(AppColors.fromHex(w.colorHex), CircleShape))
            Spacer(Modifier.width(10.dp))
            Text(w.name, style = AppTypography.listTitle.copy(fontWeight = FontWeight.Bold))
            Spacer(Modifier.weight(1f))
            Text(compactIdr(w.balance), style = AppTypography.listSubtitle)
        }
    }

    // material DropdownButton look: selected item + trailing arrow, 48dp tall, menu on canvasCardSurface
    @Composable
    private fun Dropdown(
        modifier: Modifier,
        selected: (@Composable () -> Unit)?,
        options: List<Pair<String, @Composable () -> Unit>>,
        onChanged: (String?) -> Unit,
    ) {
        var expanded by remember { mutableStateOf(false) }
        Box(modifier = modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .clickable(enabled = options.isNotEmpty()) { expanded = true }
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(Modifier.weight(1f)) { selected?.invoke() }
                Icon(Icons.Rounded.ArrowDropDown, contentDescription = null, tint = AppColors.textMuted)
            }
            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false },
                containerColor = AppColors.canvasCardSurface,
            ) {
                options.forEach { (id, content) ->
                    DropdownMenuItem(
                        text = content,
                        onClick = {
                            expanded = false
                            onChanged(id)
                        },
                    )
                }
            }
        }
    }

    // port of intl NumberFormat.compactSimpleCurrency(locale: 'id_ID')
    private fun compactIdr(value: Double): String {
        val a = abs(value)
        val (scaled, suffix) = when {
            a >= 1e12 -> value / 1e12 to " T"
            a >= 1e9 -> value / 1e9 to " M"
            a >= 1e6 -> value / 1e6 to " jt"
            a >= 1e3 -> value / 1e3 to " rb"
            else -> value to ""
        }
        val fmt = DecimalFormat(if (abs(scaled) < 100 && suffix.isNotEmpty()) "#,##0.#" else "#,##0", DecimalFormatSymbols(Locale.forLanguageTag("id-ID")))
        fmt.roundingMode = RoundingMode.HALF_EVEN
        return "Rp" + fmt.format(scaled) + suffix
    }
}
