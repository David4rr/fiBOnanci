package com.fibonanci.app.ui.health

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fibonanci.app.ui.LocalFinance
import com.fibonanci.app.ui.common.ExpandableModalSheet
import com.fibonanci.app.ui.common.ModalGrabHandle
import com.fibonanci.app.ui.common.ModalHeader
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind
import com.fibonanci.app.ui.theme.AppColors

fun showFinancialHealthModal(host: ModalHost) {
    host.show(ModalKind.Sheet) { dismiss ->
        val state by LocalFinance.current.state.collectAsStateWithLifecycle()
        val report = state.healthReport
        // port of DraggableScrollableSheet(initial 0.9, min 0.6, max 0.96, no snapping)
        ExpandableModalSheet(
            onDismiss = dismiss,
            initialChildSize = 0.9,
            minChildSize = 0.6,
            maxChildSize = 0.96,
            snapSizes = emptyList(),
            backgroundColor = AppColors.canvasBg,
            borderColor = Color.Transparent,
        ) {
            Column(Modifier.fillMaxSize()) {
                ModalGrabHandle(padding = PaddingValues(top = 16.dp, bottom = 8.dp))
                Box(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp)) {
                    ModalHeader(
                        title = "Audit Kesehatan Finansial",
                        subtitle = "Berdasarkan rasio arus kas, aset, & tagihan riil",
                        padding = PaddingValues(0.dp),
                        onClose = dismiss,
                    )
                }
                Box(Modifier.weight(1f)) {
                    FinancialHealthTab(report = report)
                }
            }
        }
    }
}
