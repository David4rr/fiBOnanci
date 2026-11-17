package com.fibonanci.app.core.format

import java.math.BigDecimal
import java.math.RoundingMode
import java.net.HttpURLConnection
import java.net.URL
import kotlin.math.abs
import kotlin.math.floor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject

/**
 * centralized currency symbol, offline exchange rate, & formatter resolver.
 * all database records remain stored in base idr to prevent rounding drift.
 */
object AppCurrency {
    private val symbols = mapOf(
        "IDR" to "Rp ",
        "USD" to "$ ",
        "EUR" to "€ ",
        "SGD" to "S$ ",
        "MYR" to "RM ",
        "JPY" to "¥ ",
    )

    /** default offline benchmark rates (1 unit of currency = x idr). */
    val defaultRatesToIdr: Map<String, Double> = linkedMapOf(
        "IDR" to 1.0,
        "USD" to 16000.0,
        "EUR" to 17500.0,
        "SGD" to 12000.0,
        "MYR" to 3600.0,
        "JPY" to 105.0,
    )

    private val ratesToIdr = HashMap(defaultRatesToIdr)

    @Volatile
    var isLiveRate = false

    private fun norm(code: String? = null): String = (code ?: "IDR").trim().uppercase()

    fun symbolFor(code: String? = null): String {
        val c = norm(code)
        return symbols[c] ?: "$c "
    }

    fun rateFor(code: String? = null): Double = synchronized(ratesToIdr) { ratesToIdr[norm(code)] } ?: 1.0

    fun setRate(code: String, idrPerUnit: Double) {
        val c = norm(code)
        if (c == "IDR" || idrPerUnit <= 0) return
        synchronized(ratesToIdr) { ratesToIdr[c] = idrPerUnit }
        isLiveRate = false
    }

    fun resetRates() {
        synchronized(ratesToIdr) {
            ratesToIdr.clear()
            ratesToIdr.putAll(defaultRatesToIdr)
        }
        isLiveRate = false
    }

    /** fetches live market exchange rates against idr; silently keeps cached/offline rates if offline. */
    suspend fun syncLiveRates(): Boolean = withContext(Dispatchers.IO) {
        var conn: HttpURLConnection? = null
        try {
            conn = URL("https://open.er-api.com/v6/latest/IDR").openConnection() as HttpURLConnection
            conn.connectTimeout = 4000
            conn.readTimeout = 4000
            if (conn.responseCode != 200) return@withContext false
            val body = conn.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
            val rates = JSONObject(body).optJSONObject("rates") ?: return@withContext false
            synchronized(ratesToIdr) {
                for (code in defaultRatesToIdr.keys) {
                    if (code == "IDR" || !rates.has(code) || rates.isNull(code)) continue
                    val perIdr = rates.getDouble(code)
                    if (perIdr > 0) ratesToIdr[code] = roundHalfAway(1.0 / perIdr)
                }
            }
            isLiveRate = true
            true
        } catch (_: Exception) {
            false
        } finally {
            conn?.disconnect()
        }
    }

    fun fromBaseIdr(idrAmount: Double, code: String? = null): Double {
        val rate = rateFor(code)
        return if (rate <= 0) idrAmount else idrAmount / rate
    }

    fun toBaseIdr(amountInCurrency: Double, code: String? = null): Double = amountInCurrency * rateFor(code)

    fun formatIdrForInput(idrAmount: Double, code: String? = null): String =
        RupiahInputFormatter.format(roundHalfAway(fromBaseIdr(idrAmount, code)))

    fun parseInputToIdr(text: String, code: String? = null): Double =
        toBaseIdr(RupiahInputFormatter.parse(text), code)

    /** == dart `AppCurrency.forCode(code, signPrefix).format(x)` (converted, id_ID currency pattern). */
    fun format(idrAmount: Double, code: String? = null, signPrefix: String = ""): String {
        val c = norm(code)
        val symbol = signPrefix + symbolFor(c)
        val converted = fromBaseIdr(idrAmount, c)
        val isWhole = abs(converted - roundHalfAway(converted)) < 0.005
        return if (c == "IDR" || c == "JPY" || isWhole) {
            formatCurrency(roundHalfAway(converted), symbol, 0)
        } else {
            formatCurrency(converted, symbol, 2)
        }
    }

    // mirrors intl NumberFormat.currency(locale: 'id_ID') : "-Rp 1.000,50"
    private fun formatCurrency(value: Double, symbol: String, decimalDigits: Int): String {
        val negative = value < 0
        var scaled = roundHalfAway(abs(value) * if (decimalDigits == 2) 100.0 else 1.0).toLong()
        val sb = StringBuilder()
        if (negative && scaled != 0L) sb.append('-')
        sb.append(symbol)
        if (decimalDigits == 2) {
            val frac = scaled % 100
            scaled /= 100
            sb.append(RupiahInputFormatter.groupDigits(scaled))
            sb.append(',').append(frac.toString().padStart(2, '0'))
        } else {
            sb.append(RupiahInputFormatter.groupDigits(scaled))
        }
        return sb.toString()
    }

    /** formats compact values (jt / rb / k / m) after converting from base idr. */
    fun formatCompact(idrVal: Double, code: String? = null): String {
        val c = norm(code)
        val sym = symbolFor(c)
        val v = fromBaseIdr(idrVal, c)
        if (c == "IDR") {
            if (v >= 1000000) return "$sym${fixed(v / 1000000, 1)} Jt"
            if (v >= 1000) return "$sym${fixed(v / 1000, 0)} Rb"
            return "$sym${fixed(v, 0)}"
        }
        if (v >= 1000000) return "$sym${fixed(v / 1000000, 1)}M"
        if (v >= 1000) return "$sym${fixed(v / 1000, 1)}k"
        val isWhole = abs(v - roundHalfAway(v)) < 0.005
        return "$sym${fixed(v, if (isWhole) 0 else 1)}"
    }

    // dart toStringAsFixed (exact binary value, half away from zero)
    private fun fixed(v: Double, digits: Int): String =
        BigDecimal(v).setScale(digits, RoundingMode.HALF_UP).toPlainString()

    // dart roundToDouble (half away from zero)
    private fun roundHalfAway(v: Double): Double = if (v < 0) -floor(-v + 0.5) else floor(v + 0.5)
}
