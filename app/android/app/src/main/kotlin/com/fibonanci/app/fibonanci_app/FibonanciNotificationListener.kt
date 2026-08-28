package com.fibonanci.app.fibonanci_app

import android.util.Log
import android.app.Notification
import android.content.Context
import android.content.SharedPreferences
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

class FibonanciNotificationListener : NotificationListenerService() {

    companion object {
        private const val PREFS_NAME = "fibonanci_notification_prefs"
        private const val KEY_PENDING = "pending_notifications"

        // Whitelist of supported Indonesian banking and e-wallet package names
        val WHITELIST = setOf(
            "id.co.bankbkemobile.digitalbank",
            "com.sea.bank",
            "com.seabank.id",
            "com.bca",
            "com.bca.mybca",
            "com.bcadigital.blu",
            "com.bankmandiri.livin",
            "com.bankjago.app",
            "ovo.id",
            "com.gojek.app",
            "id.dana",
            "com.shopee.id",
            "id.co.bri.brimo",
            "id.co.bni.wondr"
        )

        var liveNotificationListener: ((Map<String, Any>) -> Unit)? = null

        fun getAndClearPending(context: Context): List<Map<String, Any>> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonString = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            val result = mutableListOf<Map<String, Any>>()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val map = mutableMapOf<String, Any>()
                val keys = obj.keys()
                while (keys.hasNext()) {
                    val key = keys.next()
                    map[key] = obj.get(key)
                }
                result.add(map)
            }

            prefs.edit().putString(KEY_PENDING, "[]").apply()
            return result
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val pkg = sbn.packageName ?: return

        val isAllowed = WHITELIST.contains(pkg) ||
                pkg.contains("seabank") ||
                pkg.contains("bke") ||
                pkg.contains("digitalbank") ||
                pkg.contains("sea.bank") ||
                pkg.contains("bca") ||
                pkg.contains("mandiri") ||
                pkg.contains("jago") ||
                pkg.contains("ovo") ||
                pkg.contains("gojek") ||
                pkg.contains("dana") ||
                pkg.contains("shopee")

        if (!isAllowed) return

        val extras = sbn.notification.extras ?: return
        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        if (title.isEmpty() && text.isEmpty()) return
        Log.d("FibonanciNL", "MATCHED notification from: $pkg | title: $title | text: $text")


        val payload = mapOf(
            "package" to pkg,
            "title" to title,
            "text" to text,
            "timestamp" to sbn.postTime
        )

        // 2. If live listener is active (app in foreground), emit directly
        val listener = liveNotificationListener
        if (listener != null) {
            listener.invoke(payload)
        } else {
            // 3. Otherwise persist in SharedPreferences queue for next app launch
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val existing = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val jsonArray = JSONArray(existing)
            val obj = JSONObject()
            obj.put("package", pkg)
            obj.put("title", title)
            obj.put("text", text)
            obj.put("timestamp", sbn.postTime)
            jsonArray.put(obj)
            prefs.edit().putString(KEY_PENDING, jsonArray.toString()).apply()
        }
    }
}
