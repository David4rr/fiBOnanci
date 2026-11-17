package com.fibonanci.app.core.reminders

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                LocalNotificationService.initialize(context)
                LocalNotificationService.rearmPersistedReminders(context)
            }
        }
    }
}
