package com.fibonanci.app.ui.pocket

import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind

// the expandable sheet fills the window and draws its own surface.
fun showPocketDetailModal(
    host: ModalHost,
    pocket: PocketEntry,
    initialTab: Int = 0,
    initialIsDeposit: Boolean = true,
) {
    host.show(ModalKind.Sheet) { dismiss ->
        PocketDetailSheet(
            pocket = pocket,
            initialTab = initialTab,
            initialIsDeposit = initialIsDeposit,
            onDismiss = dismiss,
        )
    }
}

object PocketDetailModal {
    fun showTransferDialog(host: ModalHost, pocket: PocketEntry, isDeposit: Boolean) {
        showPocketDetailModal(host, pocket = pocket, initialTab = 1, initialIsDeposit = isDeposit)
    }
}
