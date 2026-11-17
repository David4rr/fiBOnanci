package com.fibonanci.app.ui.inbox

import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.ui.common.ModalHost
import com.fibonanci.app.ui.common.ModalKind

fun showPendingInboxModal(host: ModalHost) {
    val initialPending = NotificationBridge.getPendingRawNotifications()
    host.show(ModalKind.Sheet) { dismiss ->
        PendingInboxSheet(initialPending = initialPending, onDismiss = dismiss)
    }
}
