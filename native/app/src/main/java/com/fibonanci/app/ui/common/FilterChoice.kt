package com.fibonanci.app.ui.common

/** filter choice item for expandable search filter dropdowns. */
data class FilterChoice(
    val value: String,
    val label: String,
    val chipLabel: String? = null,
)

/** default transaction type filter options (dashboard, expense history, wallet detail). */
val kDefaultTransactionTypeChoices = listOf(
    FilterChoice(value = "all", label = "Semua"),
    FilterChoice(value = "expense", label = "Pengeluaran", chipLabel = "Tipe: EXPENSE"),
    FilterChoice(value = "income", label = "Pemasukan", chipLabel = "Tipe: PEMASUKAN"),
    FilterChoice(value = "transfer", label = "Transfer", chipLabel = "Tipe: TRANSFER"),
)

/** default subscription / recurring bill status filter options (tagihan & langganan). */
val kDefaultSubscriptionStatusChoices = listOf(
    FilterChoice(value = "all", label = "Semua Status"),
    FilterChoice(value = "unpaid", label = "Belum Bayar", chipLabel = "Status: Belum Bayar"),
    FilterChoice(value = "paid", label = "Sudah Lunas", chipLabel = "Status: Sudah Lunas"),
)
