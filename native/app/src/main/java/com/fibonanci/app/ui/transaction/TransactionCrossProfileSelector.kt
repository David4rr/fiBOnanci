package com.fibonanci.app.ui.transaction

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalanceWallet
import androidx.compose.material.icons.rounded.Person
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.WalletEntry
import com.fibonanci.app.ui.theme.AppColors
import com.fibonanci.app.ui.theme.AppTypography

@Composable
fun TransactionTransferDestinationSelector(
    profiles: List<ProfileEntry>,
    currentProfile: ProfileEntry,
    selectedTargetProfileId: String,
    onTargetProfileChanged: (String) -> Unit,
    selectedDestinationWalletId: String?,
    destinationWallets: List<WalletEntry>,
    onDestinationWalletChanged: (String?) -> Unit,
) {
    val showProfilePicker = profiles.size > 1
    val isCrossProfile = selectedTargetProfileId != currentProfile.id
    val targetProfile = profiles.firstOrNull { it.id == selectedTargetProfileId } ?: currentProfile

    Column {
        if (showProfilePicker) {
            TransactionDropdownContainer {
                TransactionDropdownButton(
                    value = selectedTargetProfileId,
                    items = profiles.map { it.id },
                    onChanged = { onTargetProfileChanged(it) },
                ) { id ->
                    val p = profiles.first { it.id == id }
                    val isCurrent = p.id == currentProfile.id
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            if (isCurrent) Icons.Rounded.Person else Icons.Rounded.SwapHoriz,
                            null,
                            Modifier.size(18.dp),
                            tint = if (isCurrent) AppColors.neoMint else AppColors.neoChartreuse,
                        )
                        Spacer(Modifier.width(10.dp))
                        Text(
                            if (isCurrent) "Profil: ${p.username} (Profil Ini)" else "Profil: ${p.username} (Lintas Profil)",
                            modifier = Modifier.weight(1f),
                            style = AppTypography.listTitle,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                }
            }
            Spacer(Modifier.height(12.dp))
        }
        TransactionDropdownContainer {
            TransactionDropdownButton(
                value = selectedDestinationWalletId,
                items = destinationWallets.map { it.id },
                onChanged = { onDestinationWalletChanged(it) },
                hint = {
                    Text(
                        if (isCrossProfile) "Pilih Rekening di ${targetProfile.username}" else "Pilih Rekening Tujuan",
                        style = AppTypography.listSubtitle,
                    )
                },
            ) { id ->
                val w = destinationWallets.first { it.id == id }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Outlined.AccountBalanceWallet,
                        null,
                        Modifier.size(18.dp),
                        tint = if (isCrossProfile) AppColors.neoChartreuse else AppColors.neoCyan,
                    )
                    Spacer(Modifier.width(10.dp))
                    Text(w.name, modifier = Modifier.weight(1f), style = AppTypography.listTitle, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    if (isCrossProfile) {
                        Text("• Masuk Kas", style = AppTypography.listSubtitle.copy(fontSize = 11.sp, color = AppColors.neoMint))
                    }
                }
            }
        }
    }
}
