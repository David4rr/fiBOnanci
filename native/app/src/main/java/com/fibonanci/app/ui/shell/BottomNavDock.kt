package com.fibonanci.app.ui.shell

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalanceWallet
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.automirrored.filled.ReceiptLong
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.automirrored.outlined.ReceiptLong
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

private val navItems = listOf(
    DockItemData(index = 0, icon = Icons.Outlined.Dashboard, activeIcon = Icons.Filled.Dashboard, label = "Home"),
    DockItemData(index = 1, icon = Icons.AutoMirrored.Outlined.ReceiptLong, activeIcon = Icons.AutoMirrored.Filled.ReceiptLong, label = "Tagihan"),
    DockItemData(index = 2, icon = Icons.Outlined.AccountBalanceWallet, activeIcon = Icons.Filled.AccountBalanceWallet, label = "Wallets"),
)

@Composable
fun BottomNavDock(
    currentIndex: Int,
    onTapIndex: (Int) -> Unit,
    onAddAction: (() -> Unit)? = null,
    onCenterAction: (() -> Unit)? = null,
    onAddLongPress: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    require(onAddAction != null || onCenterAction != null) { "Either onAddAction or onCenterAction must be provided" }
    val action = onAddAction ?: onCenterAction!!
    val pillShape = RoundedCornerShape(28.dp)

    // the flutter dock blurs what is behind it (backdrop sigma 16); compose has no backdrop
    // blur, so only the same translucent obsidian fill and border are drawn. its box shadow
    // sits inside the ClipRRect in dart and is therefore clipped away, so none is drawn here.
    Box(
        modifier
            .fillMaxWidth()
            .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Bottom + WindowInsetsSides.Horizontal))
            .padding(start = 20.dp, end = 20.dp, bottom = 12.dp),
        contentAlignment = Alignment.BottomCenter,
    ) {
        Row(
            Modifier
                .widthIn(max = 420.dp)
                .fillMaxWidth()
                .height(56.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier
                    .weight(1f)
                    .height(56.dp)
                    .clip(pillShape)
                    .background(Color(0xB813141C), pillShape)
                    .border(1.2.dp, Color(0x33FFFFFF), pillShape)
                    .padding(horizontal = 6.dp),
                contentAlignment = Alignment.Center,
            ) {
                AnimatedNavDockRow(currentIndex = currentIndex, onTapIndex = onTapIndex, items = navItems)
            }
            Spacer(Modifier.width(12.dp))
            AddActionButton(onPressed = action, onLongPress = onAddLongPress)
        }
    }
}
