@file:Suppress("DEPRECATION")

package com.fibonanci.app.ui.transaction

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.CardGiftcard
import androidx.compose.material.icons.rounded.CreditCard
import androidx.compose.material.icons.rounded.DirectionsCar
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material.icons.rounded.NorthEast
import androidx.compose.material.icons.rounded.PlayCircleFilled
import androidx.compose.material.icons.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Restaurant
import androidx.compose.material.icons.rounded.Savings
import androidx.compose.material.icons.rounded.School
import androidx.compose.material.icons.rounded.ShoppingBag
import androidx.compose.material.icons.rounded.SouthWest
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material.icons.rounded.TrendingUp
import androidx.compose.material.icons.rounded.VolunteerActivism
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.graphics.vector.ImageVector
import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.ui.transaction.mapIconName as mapIconNameCommon

class TransactionCardVisuals(
    val cardColor: Color,
    val iconData: ImageVector,
    val categoryLabel: String,
    val title: String,
)

object TransactionVisualResolver {
    val pocketGold = Color(0xFFF3C759)
    val transferBlue = Color(0xFFA5B8D8)
    val incomeMint = Color(0xFF7DE697)
    val foodOchre = Color(0xFFD9B76A)
    val transportTeal = Color(0xFF45C4B0)
    val shoppingCoral = Color(0xFFFF8B73)
    val billsPeriwinkle = Color(0xFF88A9E8)
    val entertainmentLilac = Color(0xFFBCA0E8)
    val healthRose = Color(0xFFF48FB1)
    val educationCyan = Color(0xFF5DD5E8)
    val loanTerracotta = Color(0xFFF98E56)
    val donationLime = Color(0xFFB4E051)
    val defaultSlate = Color(0xFFB8C2CC)

    fun tintToPastel(hex: String, mixWhite: Float = 0.45f): Color = try {
        val clean = hex.replace("#", "").trim()
        val intVal = (if (clean.length == 6) "FF$clean" else clean).toLong(16)
        lerp(Color(intVal.toInt()), Color.White, mixWhite)
    } catch (_: Exception) {
        defaultSlate
    }

    fun mapIconName(name: String?, fallback: ImageVector = Icons.Rounded.ReceiptLong): ImageVector =
        mapIconNameCommon(name, fallback)

    fun resolve(
        tx: TransactionEntry,
        categories: List<CategoryEntry>? = null,
        pockets: List<PocketEntry>? = null,
        destWalletName: String? = null,
    ): TransactionCardVisuals {
        val notes = tx.notes ?: ""
        val lowNotes = notes.lowercase()
        val extRef = tx.externalRef ?: ""
        val isPocketRef = extRef.startsWith("pocket_") || extRef.startsWith("pocket_close_")
        val isPocket = isPocketRef || lowNotes.contains("kantong")

        if (isPocket) {
            var pocket: PocketEntry? = null
            if (isPocketRef) {
                val pId = extRef.replaceFirst("pocket_close_", "").replaceFirst("pocket_", "")
                pocket = pockets?.firstOrNull { it.id == pId }
            }
            if (pocket == null) pocket = pockets?.firstOrNull { lowNotes.contains(it.name.lowercase()) }
            val isWithdraw = lowNotes.contains("penarikan") || extRef.startsWith("pocket_close_")
            return TransactionCardVisuals(
                cardColor = if (pocket != null) tintToPastel(pocket.colorHex) else pocketGold,
                iconData = if (isWithdraw) Icons.Rounded.NorthEast else Icons.Rounded.Savings,
                categoryLabel = if (pocket != null) "KANTONG • ${pocket.name.uppercase()}" else if (isWithdraw) "PENARIKAN KANTONG" else "KANTONG TABUNGAN",
                title = notes.ifEmpty { if (isWithdraw) "Tarik dari Kantong" else "Setor ke Kantong" },
            )
        }
        if (extRef.startsWith("cross_profile_")) {
            val isInc = tx.type == "income"
            return TransactionCardVisuals(
                cardColor = if (isInc) incomeMint else transferBlue,
                iconData = if (isInc) Icons.Rounded.SouthWest else Icons.Rounded.NorthEast,
                categoryLabel = if (isInc) "TRANSFER MASUK" else "TRANSFER KELUAR",
                title = notes.ifEmpty { if (isInc) "Transfer Masuk Antar Profil" else "Transfer Keluar Antar Profil" },
            )
        }

        if (tx.type == "transfer") {
            val t = notes.ifEmpty { if (destWalletName != null) "Transfer ke $destWalletName" else "Transfer Antar Rekening" }
            return TransactionCardVisuals(transferBlue, Icons.Rounded.SwapHoriz, "TRANSFER SALDO", t)
        }

        val cat = categories?.firstOrNull { it.id == tx.categoryId }
        val catName = (cat?.name ?: "").lowercase()

        if (tx.type == "income") {
            if (catName.contains("gaji") || lowNotes.contains("gaji") || lowNotes.contains("salary")) {
                return TransactionCardVisuals(incomeMint, Icons.Rounded.AccountBalanceWallet, "GAJI & PENDAPATAN", notes.ifEmpty { "Gaji Bulanan" })
            }
            if (catName.contains("bonus") || lowNotes.contains("bonus") || lowNotes.contains("freelance")) {
                return TransactionCardVisuals(Color(0xFF6EE7B7), Icons.Rounded.AutoAwesome, "BONUS & FREELANCE", notes.ifEmpty { "Bonus / Komisi" })
            }
            if (catName.contains("investasi") || catName.contains("bunga") || lowNotes.contains("dividen")) {
                return TransactionCardVisuals(Color(0xFF86EFAC), Icons.Rounded.TrendingUp, "INVESTASI & BUNGA", notes.ifEmpty { "Hasil Investasi" })
            }
            if (lowNotes.contains("cashback") || lowNotes.contains("refund")) {
                return TransactionCardVisuals(incomeMint, Icons.Rounded.CardGiftcard, "CASHBACK & REFUND", notes.ifEmpty { "Cashback" })
            }
            return TransactionCardVisuals(
                cardColor = if (cat != null) tintToPastel(cat.colorHex) else incomeMint,
                iconData = mapIconName(cat?.iconName, fallback = Icons.Rounded.SouthWest),
                categoryLabel = cat?.name?.uppercase() ?: "PEMASUKAN",
                title = notes.ifEmpty { "Pemasukan" },
            )
        }

        val str = "$catName $lowNotes"
        fun has(vararg keys: String) = keys.any { str.contains(it) }

        if (has("makan", "food", "resto", "kopi", "cafe")) return TransactionCardVisuals(foodOchre, Icons.Rounded.Restaurant, cat?.name?.uppercase() ?: "MAKANAN & MINUMAN", notes.ifEmpty { "Makanan & Minuman" })
        if (has("transport", "gojek", "grab", "bensin", "parkir", "tol")) return TransactionCardVisuals(transportTeal, Icons.Rounded.DirectionsCar, cat?.name?.uppercase() ?: "TRANSPORTASI", notes.ifEmpty { "Transportasi" })
        if (has("belanja", "shopee", "tokopedia", "mall", "supermarket")) return TransactionCardVisuals(shoppingCoral, Icons.Rounded.ShoppingBag, cat?.name?.uppercase() ?: "BELANJA", notes.ifEmpty { "Belanja" })
        if (has("tagihan", "listrik", "pln", "pdam", "wifi", "pulsa", "bpjs")) return TransactionCardVisuals(billsPeriwinkle, Icons.Rounded.ReceiptLong, cat?.name?.uppercase() ?: "TAGIHAN & UTILITAS", notes.ifEmpty { "Tagihan & Utilitas" })
        if (has("hiburan", "netflix", "spotify", "film", "movie", "game")) return TransactionCardVisuals(entertainmentLilac, Icons.Rounded.PlayCircleFilled, cat?.name?.uppercase() ?: "HIBURAN", notes.ifEmpty { "Hiburan" })
        if (has("kesehatan", "obat", "apotek", "dokter", "klinik")) return TransactionCardVisuals(healthRose, Icons.Rounded.Favorite, cat?.name?.uppercase() ?: "KESEHATAN", notes.ifEmpty { "Kesehatan" })
        if (has("pendidikan", "buku", "kursus", "sekolah", "kuliah")) return TransactionCardVisuals(educationCyan, Icons.Rounded.School, cat?.name?.uppercase() ?: "PENDIDIKAN", notes.ifEmpty { "Pendidikan" })
        if (has("cicilan", "pinjaman", "kredit", "kpr")) return TransactionCardVisuals(loanTerracotta, Icons.Rounded.CreditCard, cat?.name?.uppercase() ?: "CICILAN", notes.ifEmpty { "Cicilan" })
        if (has("donasi", "amal", "zakat", "sedekah")) return TransactionCardVisuals(donationLime, Icons.Rounded.VolunteerActivism, cat?.name?.uppercase() ?: "DONASI & SOSIAL", notes.ifEmpty { "Donasi & Sosial" })

        return TransactionCardVisuals(
            cardColor = if (cat != null) tintToPastel(cat.colorHex) else defaultSlate,
            iconData = mapIconName(cat?.iconName, fallback = Icons.Rounded.NorthEast),
            categoryLabel = cat?.name?.uppercase() ?: "PENGELUARAN",
            title = notes.ifEmpty { "Pengeluaran" },
        )
    }
}

fun getExpenseCategoryColor(category: String?, title: String?, type: String?, index: Int): Color {
    val str = "${category ?: ""} ${title ?: ""}".lowercase()
    fun has(vararg keys: String) = keys.any { str.contains(it) }
    return when {
        type == "transfer" || has("transfer") -> TransactionVisualResolver.transferBlue
        type == "income" -> TransactionVisualResolver.incomeMint
        has("kantong") -> TransactionVisualResolver.pocketGold
        has("makan", "food", "resto", "kopi") -> TransactionVisualResolver.foodOchre
        has("transport", "grab", "gojek", "bensin") -> TransactionVisualResolver.transportTeal
        has("belanja", "shopee", "tokopedia", "shop") -> TransactionVisualResolver.shoppingCoral
        has("tagihan", "listrik", "wifi", "pulsa") -> TransactionVisualResolver.billsPeriwinkle
        has("hiburan", "spotify", "netflix", "game") -> TransactionVisualResolver.entertainmentLilac
        has("kesehatan", "obat", "dokter") -> TransactionVisualResolver.healthRose
        has("pendidikan", "buku", "kursus") -> TransactionVisualResolver.educationCyan
        else -> TransactionVisualResolver.defaultSlate
    }
}

fun getExpenseCategoryIcon(category: String?, title: String?): ImageVector {
    val str = "${category ?: ""} ${title ?: ""}".lowercase()
    fun has(vararg keys: String) = keys.any { str.contains(it) }
    return when {
        has("kantong") -> Icons.Rounded.Savings
        has("transfer") -> Icons.Rounded.SwapHoriz
        has("makan", "food", "resto", "kopi") -> Icons.Rounded.Restaurant
        has("transport", "grab", "gojek", "bensin") -> Icons.Rounded.DirectionsCar
        has("belanja", "shopee", "tokopedia", "shop") -> Icons.Rounded.ShoppingBag
        has("tagihan", "listrik", "wifi", "pulsa") -> Icons.Rounded.ReceiptLong
        has("hiburan", "netflix", "spotify", "film") -> Icons.Rounded.PlayCircleFilled
        has("kesehatan", "obat") -> Icons.Rounded.Favorite
        has("pendidikan", "buku") -> Icons.Rounded.School
        else -> Icons.Rounded.ReceiptLong
    }
}
