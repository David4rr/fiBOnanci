package com.fibonanci.app.ui.pocket

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.key
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors

fun showPocketTransferDialog(host: ModalHost, pocket: PocketEntry, isDeposit: Boolean) {
    host.show(ModalKind.Sheet) { dismiss ->
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .background(AppColors.canvasCardSurface)
                .verticalScroll(rememberScrollState())
                .padding(start = 20.dp, top = 12.dp, end = 20.dp, bottom = 24.dp),
        ) {
            ModalGrabHandle(padding = PaddingValues(bottom = 12.dp))
            ModalHeader(
                title = if (isDeposit) "Isi Dana ke Kantong" else "Tarik Dana ke Rekening",
                subtitle = if (isDeposit) {
                    "Pilih rekening asal untuk memindahkan dana ke ${pocket.name}."
                } else {
                    "Pilih rekening tujuan penarikan dari ${pocket.name}."
                },
                onClose = dismiss,
            )
            Spacer(Modifier.height(16.dp))
            key("transfer_${isDeposit}_${pocket.id}") {
                PocketTransferForm(
                    pocket = pocket,
                    isDeposit = isDeposit,
                    onSuccess = dismiss,
                    onCancel = dismiss,
                )
            }
        }
    }
}
