package com.fibonanci.app.data.db

const val TRANSFER_CATEGORY_ID = "11111111-1111-4111-8111-111111111111"
fun defaultCategoriesSeed(now: Long): List<CategoryEntry> = listOf(
    CategoryEntry(id = "11111111-1111-4111-8111-111111111101", name = "Makanan & Minuman", type = "expense", iconName = "utensils", colorHex = "#EF4444", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111102", name = "Transportasi", type = "expense", iconName = "car", colorHex = "#F97316", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111103", name = "Belanja & Kebutuhan", type = "expense", iconName = "shopping_bag", colorHex = "#F59E0B", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111104", name = "Tagihan & Utilitas", type = "expense", iconName = "receipt", colorHex = "#3B82F6", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111105", name = "Hiburan & Langganan", type = "expense", iconName = "film", colorHex = "#8B5CF6", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111106", name = "Kesehatan", type = "expense", iconName = "heart_pulse", colorHex = "#EC4899", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111107", name = "Pendidikan & Kursus", type = "expense", iconName = "graduation_cap", colorHex = "#06B6D4", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111108", name = "Gaji & Pendapatan Pokok", type = "income", iconName = "banknote", colorHex = "#10B981", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111109", name = "Bonus & Freelance", type = "income", iconName = "sparkles", colorHex = "#14B8A6", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111110", name = "Investasi & Bunga", type = "income", iconName = "trending_up", colorHex = "#22C55E", createdAt = now, updatedAt = now),
    CategoryEntry(id = "11111111-1111-4111-8111-111111111111", name = "Transfer Antar Rekening", type = "expense", iconName = "repeat", colorHex = "#64748B", createdAt = now, updatedAt = now),
)
