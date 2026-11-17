package com.fibonanci.app.ui.inbox

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
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.PlusJakartaSans

@Composable
fun InboxNotificationCard(
    bankLabel: String,
    type: String,
    amount: Double,
    counterparty: String,
    walletName: String? = null,
    profileName: String? = null,
    onSwitchWallet: (() -> Unit)? = null,
    onEdit: (() -> Unit)? = null,
    text: String,
    cardAccent: Color,
    currentIndex: Int = 0,
    totalCount: Int = 1,
    isTopCard: Boolean = true,
    modifier: Modifier = Modifier,
) {
    val state by LocalFinance.current.state.collectAsStateWithLifecycle()
    val isIncome = type == "income"
    val formattedAmount = AppCurrency.format(amount, state.profile.currency)
    val shape = RoundedCornerShape(16.dp)

    Column(
        modifier = modifier
            .fillMaxWidth()
            // flutter: black 45% shadow, blur 16, offset y 6 (top card only)
            .then(
                if (isTopCard) Modifier.shadow(
                    elevation = 8.dp,
                    shape = shape,
                    ambientColor = Color.Black.copy(alpha = 0.45f),
                    spotColor = Color.Black.copy(alpha = 0.45f),
                ) else Modifier,
            )
            .background(AppColors.canvasCardSurface, shape)
            .border(0.8.dp, if (isTopCard) AppColors.canvasBorder else Color.White.copy(alpha = 0.08f), shape)
            .padding(16.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                bankLabel.uppercase(),
                modifier = Modifier.weight(1f),
                overflow = TextOverflow.Ellipsis,
                maxLines = 1,
                style = TextStyle(
                    fontFamily = PlusJakartaSans,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.8.sp,
                    color = if (isIncome) AppColors.neoMint else AppColors.textSubtle,
                ),
            )
            Spacer(Modifier.width(8.dp))
            Box(Modifier.weight(1f, fill = false).widthIn(max = 165.dp)) {
                InboxWalletChip(
                    walletName = walletName,
                    profileName = profileName,
                    onSwitchWallet = onSwitchWallet,
                )
            }
        }
        Spacer(Modifier.height(12.dp))
        Row(
            modifier = Modifier.clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                enabled = isTopCard && onEdit != null,
            ) { onEdit?.invoke() },
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (amount > 0) {
                Text(
                    if (isIncome) "+$formattedAmount" else "-$formattedAmount",
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f, fill = false),
                    style = TextStyle(
                        fontFamily = PlusJakartaSans,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = (-0.5).sp,
                        fontFeatureSettings = "tnum",
                        color = if (isIncome) AppColors.neoMint else AppColors.neoCoral,
                    ),
                )
            }
            if (isTopCard && onEdit != null) {
                Spacer(Modifier.width(6.dp))
                Icon(
                    Icons.Outlined.Edit,
                    contentDescription = null,
                    modifier = Modifier.size(14.dp),
                    tint = if (isIncome) AppColors.neoMint.copy(alpha = 0.6f) else AppColors.neoCoral.copy(alpha = 0.6f),
                )
            }
        }
        Spacer(Modifier.height(4.dp))
        Text(
            counterparty.ifEmpty { if (isIncome) "Pemasukan" else "Pengeluaran" },
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = AppColors.textSubtle,
            ),
        )
        Spacer(Modifier.height(14.dp))
        Box(
            Modifier
                .fillMaxWidth()
                .height(0.5.dp)
                .background(Color.White.copy(alpha = 0.07f)),
        )
        Spacer(Modifier.height(12.dp))
        Text(
            text,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
            style = TextStyle(
                fontFamily = PlusJakartaSans,
                fontSize = 11.5.sp,
                fontWeight = FontWeight.Normal,
                color = AppColors.textMuted,
                lineHeight = (11.5 * 1.4).sp,
            ),
        )
    }
}
