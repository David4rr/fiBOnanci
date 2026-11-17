package com.fibonanci.app.core.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra(LocalNotificationService.EXTRA_ID, -1)
        if (id < 0) return
        val title = intent.getStringExtra(LocalNotificationService.EXTRA_TITLE) ?: return
        val body = intent.getStringExtra(LocalNotificationService.EXTRA_BODY) ?: return
        val payload = intent.getStringExtra(LocalNotificationService.EXTRA_PAYLOAD)
        LocalNotificationService.initialize(context)
        LocalNotificationService.forgetReminder(context, id)
        LocalNotificationService.postNotification(context, id, title, body, payload)
    }
}
