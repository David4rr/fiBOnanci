package com.fibonanci.app.core.notification

data class BankAppPreset(val name: String, val packageName: String) {
    override fun toString(): String = "$name ($packageName)"
}

val kPopularBankAppPresets: List<BankAppPreset> = listOf(
    BankAppPreset(name = "Krom Bank", packageName = "id.krom.bank"),
    BankAppPreset(name = "BCA (BCA Mobile)", packageName = "com.bca"),
    BankAppPreset(name = "myBCA", packageName = "com.bca.mybca"),
    BankAppPreset(name = "blu by BCA Digital", packageName = "com.bcadigital.blu"),
    BankAppPreset(name = "Livin by Mandiri", packageName = "com.bankmandiri.livin"),
    BankAppPreset(name = "Bank Jago", packageName = "com.bankjago.app"),
    BankAppPreset(name = "SeaBank Indonesia", packageName = "com.seabank.id"),
    BankAppPreset(name = "BRImo (BRI)", packageName = "id.co.bri.brimo"),
    BankAppPreset(name = "wondr by BNI", packageName = "id.co.bni.wondr"),
    BankAppPreset(name = "BSI Mobile", packageName = "com.bsi.mobile"),
    BankAppPreset(name = "Bank Neo Commerce (Neobank)", packageName = "com.bankneo.neobank"),
    BankAppPreset(name = "Jenius (BTPN)", packageName = "com.btpn.dc"),
    BankAppPreset(name = "Allo Bank", packageName = "id.allobank.mobile"),
    BankAppPreset(name = "Line Bank", packageName = "com.linecorp.linebankid"),
    BankAppPreset(name = "Superbank", packageName = "id.co.superbank.retail"),
    BankAppPreset(name = "OCTO Mobile (CIMB Niaga)", packageName = "cimb.octomobile.android"),
    BankAppPreset(name = "Permata ME", packageName = "com.bankpermata.mobile"),
    BankAppPreset(name = "Danamon D-Bank PRO", packageName = "com.danamon.dbank"),
    BankAppPreset(name = "Bank Saqu", packageName = "id.banksaqu.app"),
    BankAppPreset(name = "Flip", packageName = "id.flip"),
    BankAppPreset(name = "OVO", packageName = "ovo.id"),
    BankAppPreset(name = "GoPay / Gojek", packageName = "com.gojek.app"),
    BankAppPreset(name = "DANA", packageName = "id.dana"),
    BankAppPreset(name = "ShopeePay", packageName = "com.shopee.id"),
    BankAppPreset(name = "LinkAja", packageName = "com.telkom.mwallet"),
)

private val packageAliasGroups: List<Set<String>> = listOf(
    setOf("id.co.bankbkemobile.digitalbank", "com.seabank.id", "com.sea.bank"),
    setOf("com.jago.digitalbanking", "com.jago.digitalBanking", "com.bankjago.app", "id.co.bankjago"),
    setOf("com.bca", "com.bca.mobile"),
    setOf("com.bca.mybca", "com.bca.mybca.omni.android"),
    setOf("com.bcadigital.blu", "id.co.bcadigital.blu"),
    setOf("com.bankmandiri.livin", "id.bmri.livin", "com.bankmandiri.mandirionline"),
    setOf("id.co.bri.brimo", "com.bri.brimo"),
    setOf("id.co.bni.wondr", "id.bni.wondr", "src.com.bni"),
    setOf("com.bsi.mobile", "id.co.bankbsi.bsimobile", "co.id.bankbsi.superapp"),
    setOf("com.bankneo.neobank", "com.bnc.finance", "id.co.bankneo.neobank"),
    setOf("com.btpn.dc", "id.co.btpn.jenius"),
    setOf("id.allobank.mobile", "com.alloapp.yump", "com.allobank.allobank"),
    setOf("com.linecorp.linebankid", "id.co.linebank", "com.kebhana.linebank"),
    setOf("id.co.superbank.retail", "id.co.bankfama.superbank", "com.superbank.app"),
    setOf("cimb.octomobile.android", "id.co.cimbniaga.mobile.android"),
    setOf("com.bankpermata.mobile", "net.myinfosys.PermataMobileX", "net.myinfosys.permatamobilex", "id.co.permatabank.permatame"),
    setOf("com.danamon.dbank", "com.danamon.dbankpro", "id.co.danamon.dbankpro"),
    setOf("id.krom.bank", "com.krombank.id", "id.co.krombank"),
    setOf("id.banksaqu.app", "com.banksaqu.id"),
    setOf("id.flip"),
    setOf("ovo.id", "id.ovo"),
    setOf("com.gojek.app", "com.gojek.gopay"),
    setOf("id.dana", "com.dana"),
    setOf("com.shopee.id", "com.shopeepay.id"),
    setOf("com.telkom.mwallet", "id.linkaja"),
)

// returns all known android package name aliases for the given package name
fun expandPackageAliases(packageName: String): Set<String> {
    val clean = packageName.trim()
    val low = clean.lowercase()
    if (low.isEmpty()) return emptySet()
    val result = linkedSetOf(clean, low)
    for (group in packageAliasGroups) {
        if (group.any { it.lowercase() == low }) result.addAll(group)
    }
    return result
}

fun findBankPresetByPackage(packageName: String): BankAppPreset? {
    val aliases = expandPackageAliases(packageName).map { it.lowercase() }.toSet()
    return kPopularBankAppPresets.firstOrNull { aliases.contains(it.packageName.lowercase()) }
}
