package com.fibonanci.app.core.reminders

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.fibonanci.app.MainActivity
import com.fibonanci.app.R
import com.fibonanci.app.core.nowMillis
import com.fibonanci.app.data.db.SubscriptionEntry
import org.json.JSONObject

object LocalNotificationService {
    const val channelId = "fibonanci_bills_channel"
    const val channelName = "Pengingat Tagihan & Langganan"
    const val channelDescription = "Notifikasi offline pengingat jatuh tempo tagihan dan cicilan"

    const val EXTRA_ID = "reminder_id"
    const val EXTRA_TITLE = "reminder_title"
    const val EXTRA_BODY = "reminder_body"
    const val EXTRA_PAYLOAD = "reminder_payload"

    private const val PREFS = "fibonanci_scheduled_reminders"
    private const val REQUEST_PERMISSION_CODE = 9413

    var isInitialized: Boolean = false
        private set

    fun initialize(context: Context): Boolean {
        if (isInitialized) return true
        return try {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return false
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH).apply {
                description = channelDescription
                enableVibration(true)
            }
            manager.createNotificationChannel(channel)
            isInitialized = true
            true
        } catch (e: Exception) {
            Log.w("LocalNotificationService", "LocalNotificationService initialize error: $e")
            false
        }
    }

    // returns true when already granted; otherwise asks and returns false (result arrives async)
    fun requestPermissions(activity: Activity): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        if (activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
            return true
        }
        activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_PERMISSION_CODE)
        return false
    }

    fun scheduleSubscriptionReminders(context: Context, sub: SubscriptionEntry, referenceDate: Long? = null) {
        if (!isInitialized) return
        if (sub.isDeleted || sub.status != "active") {
            cancelSubscriptionReminders(context, sub.id)
            return
        }

        val reminders = SubscriptionNotificationCalculator.calculateReminders(
            subscriptionId = sub.id,
            title = sub.title,
            cost = sub.cost,
            dueDay = sub.dueDay,
            billingCycle = sub.billingCycle,
            isInstallment = sub.isInstallment,
            totalCycles = sub.totalCycles,
            paidCycles = sub.paidCycles,
            deadlineDate = sub.deadlineDate,
            lastPaidDate = sub.lastPaidDate,
            referenceDate = referenceDate,
        )

        cancelSubscriptionReminders(context, sub.id)

        for (reminder in reminders) {
            try {
                arm(context, reminder.id, reminder.scheduledTime, reminder.title, reminder.body, reminder.payload)
                persist(context, reminder)
            } catch (e: Exception) {
                Log.w("LocalNotificationService", "Failed to schedule reminder ${reminder.id}: $e")
            }
        }
    }

    fun cancelSubscriptionReminders(context: Context, subscriptionId: String) {
        if (!isInitialized) return
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        val manager = context.getSystemService(NotificationManager::class.java)
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
        for (id in SubscriptionNotificationCalculator.getAllReminderIds(subscriptionId)) {
            try {
                val pending = PendingIntent.getBroadcast(
                    context, id, Intent(context, ReminderReceiver::class.java),
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
                )
                if (pending != null) {
                    alarmManager?.cancel(pending)
                    pending.cancel()
                }
                manager?.cancel(id)
                prefs.remove(id.toString())
            } catch (_: Exception) {
            }
        }
        prefs.apply()
    }

    fun syncAllSubscriptionReminders(context: Context, subscriptions: List<SubscriptionEntry>, referenceDate: Long? = null) {
        for (sub in subscriptions) {
            if (sub.isDeleted || sub.status != "active") {
                cancelSubscriptionReminders(context, sub.id)
            } else {
                scheduleSubscriptionReminders(context, sub, referenceDate)
            }
        }
    }

    fun showInstantReceipt(context: Context, id: Int, title: String, body: String, payload: String? = null) {
        if (!isInitialized) return
        try {
            postNotification(context, id, title, body, payload)
        } catch (e: Exception) {
            Log.w("LocalNotificationService", "Failed to show instant notification: $e")
        }
    }

    internal fun postNotification(context: Context, id: Int, title: String, body: String, payload: String?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        val tapIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_PAYLOAD, payload)
        }
        val contentIntent = PendingIntent.getActivity(
            context, id, tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = Notification.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .build()
        context.getSystemService(NotificationManager::class.java)?.notify(id, notification)
    }

    private fun arm(context: Context, id: Int, time: Long, title: String, body: String, payload: String) {
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            putExtra(EXTRA_ID, id)
            putExtra(EXTRA_TITLE, title)
            putExtra(EXTRA_BODY, body)
            putExtra(EXTRA_PAYLOAD, payload)
        }
        val pending = PendingIntent.getBroadcast(
            context, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val canExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
        if (canExact) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pending)
        } else {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pending)
        }
    }

    private fun persist(context: Context, reminder: ScheduledBillReminder) {
        val json = JSONObject()
            .put("id", reminder.id)
            .put("time", reminder.scheduledTime)
            .put("title", reminder.title)
            .put("body", reminder.body)
            .put("payload", reminder.payload)
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putString(reminder.id.toString(), json.toString())
            .apply()
    }

    internal fun forgetReminder(context: Context, id: Int) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().remove(id.toString()).apply()
    }

    // re-arms persisted reminders after reboot / update; past ones are dropped
    fun rearmPersistedReminders(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val now = nowMillis()
        val editor = prefs.edit()
        for ((key, value) in prefs.all) {
            try {
                val json = JSONObject(value as String)
                val time = json.getLong("time")
                if (time <= now) {
                    editor.remove(key)
                    continue
                }
                arm(context, json.getInt("id"), time, json.getString("title"), json.getString("body"), json.getString("payload"))
            } catch (_: Exception) {
                editor.remove(key)
            }
        }
        editor.apply()
    }
}
