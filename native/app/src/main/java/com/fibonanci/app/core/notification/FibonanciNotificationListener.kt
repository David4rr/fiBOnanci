package com.fibonanci.app.core.notification

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.fibonanci.app.core.security.SecurityVault
import org.json.JSONArray
import org.json.JSONObject

class FibonanciNotificationListener : NotificationListenerService() {

    companion object {
        private const val PREFS_NAME = "fibonanci_notification_prefs"
        private const val KEY_PENDING = "pending_notifications"
        private const val KEY_DYNAMIC_WHITELIST = "dynamic_whitelist"

        // whitelist of supported indonesian banking and e-wallet package names
        val WHITELIST = setOf(
            "id.co.bankbkemobile.digitalbank", "com.sea.bank", "com.seabank.id",
            "com.bca", "com.bca.mobile", "com.bca.mybca", "com.bca.mybca.omni.android",
            "com.bcadigital.blu", "id.co.bcadigital.blu",
            "com.bankmandiri.livin", "id.bmri.livin", "com.bankmandiri.mandirionline",
            "com.bankjago.app", "com.jago.digitalBanking", "com.jago.digitalbanking", "id.co.bankjago",
            "id.co.bri.brimo", "com.bri.brimo",
            "id.co.bni.wondr", "id.bni.wondr", "src.com.bni",
            "com.bsi.mobile", "id.co.bankbsi.bsimobile", "co.id.bankbsi.superapp",
            "com.bankneo.neobank", "com.bnc.finance", "id.co.bankneo.neobank",
            "com.btpn.dc", "id.co.btpn.jenius",
            "id.allobank.mobile", "com.alloapp.yump", "com.allobank.allobank",
            "com.linecorp.linebankid", "id.co.linebank", "com.kebhana.linebank",
            "id.co.superbank.retail", "id.co.bankfama.superbank", "com.superbank.app",
            "cimb.octomobile.android", "id.co.cimbniaga.mobile.android",
            "com.bankpermata.mobile", "net.myinfosys.PermataMobileX", "id.co.permatabank.permatame",
            "com.danamon.dbank", "com.danamon.dbankpro", "id.co.danamon.dbankpro",
            "id.krom.bank", "com.krombank.id", "id.co.krombank",
            "id.banksaqu.app", "com.banksaqu.id", "id.flip",
            "ovo.id", "id.ovo", "com.gojek.app", "com.gojek.gopay",
            "id.dana", "com.dana", "com.shopee.id", "com.shopeepay.id",
            "com.telkom.mwallet", "id.linkaja",
        )

        private val PACKAGE_TOKENS = listOf(
            "seabank", "bke", "digitalbank", "sea.bank", "bca", "blu", "mandiri", "livin", "jago", "krom",
            "brimo", "bri", "wondr", "bni", "bsi", "byond", "bnc", "neobank", "bankneo", "btpn", "jenius",
            "allo", "linebank", "superbank", "bankfama", "cimb", "octo", "permata", "danamon", "dbank",
            "banksaqu", "flip", "ovo", "gojek", "gopay", "dana", "shopee", "mwallet", "linkaja",
        )

        @Volatile
        var isAppForeground: Boolean = false

        @Volatile
        var liveNotificationListener: ((Map<String, Any?>) -> Unit)? = null

        fun setDynamicWhitelist(context: Context, packages: List<String>) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val encrypted = SecurityVault.encryptString(JSONArray(packages).toString())
            prefs.edit().putString(KEY_DYNAMIC_WHITELIST, encrypted).apply()
        }

        fun getDynamicWhitelist(context: Context): Set<String> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val rawString = prefs.getString(KEY_DYNAMIC_WHITELIST, "[]") ?: "[]"
            val jsonString = SecurityVault.decryptString(rawString)
            val result = mutableSetOf<String>()
            try {
                val jsonArray = JSONArray(jsonString)
                for (i in 0 until jsonArray.length()) {
                    val p = jsonArray.optString(i)
                    if (p.isNotEmpty()) result.add(p)
                }
            } catch (_: Exception) {
            }
            return result
        }

        @Synchronized
        fun getAndClearPending(context: Context): List<Map<String, Any?>> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val rawString = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val jsonString = SecurityVault.decryptString(rawString)
            val result = mutableListOf<Map<String, Any?>>()
            try {
                val jsonArray = JSONArray(jsonString)
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    val map = mutableMapOf<String, Any?>()
                    val keys = obj.keys()
                    while (keys.hasNext()) {
                        val key = keys.next()
                        map[key] = obj.get(key)
                    }
                    result.add(map)
                }
            } catch (_: Exception) {
            }
            prefs.edit().putString(KEY_PENDING, SecurityVault.encryptString("[]")).apply()
            return result
        }

        @Synchronized
        private fun appendPending(context: Context, pkg: String, title: String, text: String, postTime: Long) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val rawExisting = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val existing = SecurityVault.decryptString(rawExisting)
            val jsonArray = try { JSONArray(existing) } catch (_: Exception) { JSONArray() }
            val obj = JSONObject()
            obj.put("package", pkg)
            obj.put("title", title)
            obj.put("text", text)
            obj.put("timestamp", postTime)
            jsonArray.put(obj)
            prefs.edit().putString(KEY_PENDING, SecurityVault.encryptString(jsonArray.toString())).apply()
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val pkg = sbn.packageName ?: return
        val lowPkg = pkg.lowercase()

        val dynamicWhitelist = getDynamicWhitelist(applicationContext).map { it.lowercase() }.toSet()
        val isAllowed = WHITELIST.any { it.equals(pkg, ignoreCase = true) } ||
            dynamicWhitelist.contains(lowPkg) ||
            PACKAGE_TOKENS.any { lowPkg.contains(it) }
        if (!isAllowed) return

        val extras = sbn.notification.extras ?: return
        val title = (extras.getCharSequence(Notification.EXTRA_TITLE)
            ?: extras.getCharSequence(Notification.EXTRA_TITLE_BIG))?.toString()?.trim() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim()
        val normalText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()?.trim()
        val infoText = extras.getCharSequence(Notification.EXTRA_INFO_TEXT)?.toString()?.trim()
        val textLines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
            ?.mapNotNull { it?.toString()?.trim() }
            ?.filter { it.isNotEmpty() }
            ?.joinToString(" ")
        val tickerText = sbn.notification.tickerText?.toString()?.trim()
        val text = when {
            !bigText.isNullOrEmpty() && !normalText.isNullOrEmpty() && !bigText.contains(normalText, ignoreCase = true) ->
                "$normalText. $bigText"
            !bigText.isNullOrEmpty() -> bigText
            !normalText.isNullOrEmpty() -> normalText
            !textLines.isNullOrEmpty() -> textLines
            !subText.isNullOrEmpty() -> subText
            !infoText.isNullOrEmpty() -> infoText
            !tickerText.isNullOrEmpty() -> tickerText
            else -> ""
        }
        if (title.isEmpty() && text.isEmpty()) return
        val isGroupSummary = (sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY) != 0
        if (isGroupSummary && !text.any { it.isDigit() }) return

        Log.d("FibonanciNL", "MATCHED notification from: $pkg | title: $title | text: $text")

        val payload = mapOf<String, Any?>(
            "package" to pkg,
            "title" to title,
            "text" to text,
            "timestamp" to sbn.postTime,
        )

        val listener = liveNotificationListener
        if (isAppForeground && listener != null) {
            try {
                listener.invoke(payload)
                return
            } catch (_: Exception) {
            }
        }

        appendPending(applicationContext, pkg, title, text, sbn.postTime)
    }
}
