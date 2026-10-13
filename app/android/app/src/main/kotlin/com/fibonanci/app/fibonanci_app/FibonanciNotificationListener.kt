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
        private const val KEY_DYNAMIC_WHITELIST = "dynamic_whitelist"

        // Whitelist of supported Indonesian banking and e-wallet package names
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
            "com.telkom.mwallet", "id.linkaja"
        )
        @Volatile
        var isAppForeground: Boolean = false
        var liveNotificationListener: ((Map<String, Any>) -> Unit)? = null
        fun setDynamicWhitelist(context: Context, packages: List<String>) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonArray = JSONArray(packages)
            val encrypted = SecurityVaultHelper.encryptString(jsonArray.toString())
            prefs.edit().putString(KEY_DYNAMIC_WHITELIST, encrypted).apply()
        }

        fun getDynamicWhitelist(context: Context): Set<String> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val rawString = prefs.getString(KEY_DYNAMIC_WHITELIST, "[]") ?: "[]"
            val jsonString = SecurityVaultHelper.decryptString(rawString)
            val result = mutableSetOf<String>()
            try {
                val jsonArray = JSONArray(jsonString)
                for (i in 0 until jsonArray.length()) {
                    val p = jsonArray.optString(i)
                    if (p.isNotEmpty()) {
                        result.add(p)
                    }
                }
            } catch (_: Exception) {}
            return result
        }

        fun getAndClearPending(context: Context): List<Map<String, Any>> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val rawString = prefs.getString(KEY_PENDING, "[]") ?: "[]"
            val jsonString = SecurityVaultHelper.decryptString(rawString)
            val result = mutableListOf<Map<String, Any>>()

            try {
                val jsonArray = JSONArray(jsonString)
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
            } catch (_: Exception) {}

            prefs.edit().putString(KEY_PENDING, SecurityVaultHelper.encryptString("[]")).apply()
            return result
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
                lowPkg.contains("seabank") || lowPkg.contains("bke") || lowPkg.contains("digitalbank") || lowPkg.contains("sea.bank") ||
                lowPkg.contains("bca") || lowPkg.contains("blu") ||
                lowPkg.contains("mandiri") || lowPkg.contains("livin") ||
                lowPkg.contains("jago") || lowPkg.contains("krom") ||
                lowPkg.contains("brimo") || lowPkg.contains("bri") ||
                lowPkg.contains("wondr") || lowPkg.contains("bni") ||
                lowPkg.contains("bsi") || lowPkg.contains("byond") ||
                lowPkg.contains("bnc") || lowPkg.contains("neobank") || lowPkg.contains("bankneo") ||
                lowPkg.contains("btpn") || lowPkg.contains("jenius") ||
                lowPkg.contains("allo") || lowPkg.contains("linebank") ||
                lowPkg.contains("superbank") || lowPkg.contains("bankfama") ||
                lowPkg.contains("cimb") || lowPkg.contains("octo") ||
                lowPkg.contains("permata") || lowPkg.contains("danamon") || lowPkg.contains("dbank") ||
                lowPkg.contains("banksaqu") || lowPkg.contains("flip") ||
                lowPkg.contains("ovo") || lowPkg.contains("gojek") || lowPkg.contains("gopay") ||
                lowPkg.contains("dana") || lowPkg.contains("shopee") ||
                lowPkg.contains("mwallet") || lowPkg.contains("linkaja")
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

        val payload = mapOf(
            "package" to pkg,
            "title" to title,
            "text" to text,
            "timestamp" to sbn.postTime
        )

        val listener = liveNotificationListener
        if (isAppForeground && listener != null) {
            try {
                listener.invoke(payload)
                return
            } catch (_: Exception) {}
        }

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val rawExisting = prefs.getString(KEY_PENDING, "[]") ?: "[]"
        val existing = SecurityVaultHelper.decryptString(rawExisting)
        val jsonArray = try { JSONArray(existing) } catch (_: Exception) { JSONArray() }
        val obj = JSONObject()
        obj.put("package", pkg)
        obj.put("title", title)
        obj.put("text", text)
        obj.put("timestamp", sbn.postTime)
        jsonArray.put(obj)
        prefs.edit().putString(KEY_PENDING, SecurityVaultHelper.encryptString(jsonArray.toString())).apply()
    }
}
