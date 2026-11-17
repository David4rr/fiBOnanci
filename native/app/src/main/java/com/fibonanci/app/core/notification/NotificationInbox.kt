package com.fibonanci.app.core.notification

import com.fibonanci.app.data.FinanceRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

// in-memory buffer and review queue for incoming push notifications
object NotificationInbox {
    private val pendingNotifications = mutableListOf<Map<String, Any?>>()
    private val _pendingCount = MutableStateFlow(0)
    private val _pendingItems = MutableStateFlow<List<Map<String, Any?>>>(emptyList())

    val pendingCount: StateFlow<Int> = _pendingCount.asStateFlow()
    val pendingItems: StateFlow<List<Map<String, Any?>>> = _pendingItems.asStateFlow()

    private fun publish() {
        _pendingItems.value = pendingNotifications.toList()
        _pendingCount.value = pendingNotifications.size
    }

    @Synchronized
    fun isDuplicatePending(item: Map<String, Any?>): Boolean = pendingNotifications.any { p ->
        (item["transactionId"] != null && p["transactionId"] == item["transactionId"]) ||
            (p["package"] == item["package"] &&
                p["text"] == item["text"] &&
                (p["timestamp"] == item["timestamp"] || (p["title"] == item["title"] && item["title"] != null)))
    }

    @Synchronized
    fun addPending(item: Map<String, Any?>) {
        if (!isDuplicatePending(item)) {
            pendingNotifications.add(item)
            publish()
        }
    }

    // retrieve pending notifications buffered in memory
    @Synchronized
    fun getPendingRawNotifications(): List<Map<String, Any?>> {
        publish()
        return pendingNotifications.toList()
    }

    // removes a processed or discarded notification from pending list
    @Synchronized
    fun removePendingNotification(raw: Map<String, Any?>) {
        pendingNotifications.removeAll { p ->
            (raw["transactionId"] != null && p["transactionId"] == raw["transactionId"]) ||
                (p["package"] == raw["package"] &&
                    p["text"] == raw["text"] &&
                    (p["timestamp"] == raw["timestamp"] || p["title"] == raw["title"]))
        }
        publish()
    }

    // confirm that an auto-logged notification is correct; removes it from the inbox
    fun confirmNotification(item: Map<String, Any?>) {
        removePendingNotification(item)
    }

    // mark notification as incorrect: deletes the auto-logged transaction, reverts balance, and removes from inbox
    suspend fun rejectNotification(item: Map<String, Any?>, repository: FinanceRepository) {
        val txId = item["transactionId"] as? String
        if (!txId.isNullOrEmpty()) {
            try {
                repository.deleteTransaction(txId)
            } catch (_: Exception) {
            }
        }
        removePendingNotification(item)
    }

    // clears all pending notifications
    @Synchronized
    fun clearPendingNotifications() {
        pendingNotifications.clear()
        publish()
    }
}
