package com.fibonanci.app.ui.profile

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fibonanci.app.core.format.AppCurrency
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.ui.theme.AppColors

// port of the static ProfileGeneralDataCard.buildDataRow
@Composable
fun ProfileDataRow(
    icon: ImageVector? = null,
    label: String,
    value: String,
    valueColor: Color? = null,
    isMuted: Boolean = false,
) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        Text(label, style = jakarta(12.5.sp, FontWeight.Medium, AppColors.textMuted))
        Spacer(Modifier.width(16.dp))
        Text(
            value,
            style = jakarta(
                12.5.sp,
                FontWeight.SemiBold,
                valueColor ?: (if (isMuted) AppColors.textMuted else AppColors.textWhite),
                tabular = true,
            ),
            textAlign = TextAlign.End,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f, fill = false),
        )
    }
}

@Composable
fun ProfileGeneralDataCard(
    profile: ProfileEntry,
    walletCount: Int,
    txCount: Int,
) {
    val income = profile.monthlyIncomeTarget
    val hasIncome = income != null && income > 0
    val hasPhone = !profile.phone.isNullOrEmpty()
    val hasOcc = !profile.occupation.isNullOrEmpty()
    val hasBio = !profile.bio.isNullOrEmpty()

    Column(Modifier.fillMaxWidth()) {
        Text(
            "DATA UMUM & DETAIL AKUN",
            style = jakarta(10.5.sp, FontWeight.Bold, AppColors.textMuted, letterSpacing = 0.8.sp),
        )
        Spacer(Modifier.height(8.dp))
        ProfileDataRow(label = "Profesi / Pekerjaan", value = if (hasOcc) profile.occupation!! else "—", isMuted = !hasOcc)
        ProfileDataRow(label = "No. Handphone", value = if (hasPhone) profile.phone!! else "—", isMuted = !hasPhone)
        if (hasBio) ProfileDataRow(label = "Bio / Catatan", value = profile.bio!!)
        ProfileDataRow(
            label = "Mata Uang Utama",
            value = "${profile.currency} (${if (profile.currency == "IDR") "Rupiah" else profile.currency})",
        )
        ProfileDataRow(
            label = "Target Pemasukan",
            value = if (hasIncome) AppCurrency.format(income!!, profile.currency) else "—",
            isMuted = !hasIncome,
        )
        ProfileDataRow(label = "Rekening Terhubung", value = "$walletCount Akun")
        ProfileDataRow(label = "Total Transaksi", value = "$txCount Tercatat")
    }
}
