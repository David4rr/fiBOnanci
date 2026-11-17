package com.fibonanci.app.ui.transaction

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccountBalanceWallet
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.DirectionsCar
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material.icons.rounded.Flag
import androidx.compose.material.icons.rounded.MusicNote
import androidx.compose.material.icons.rounded.PlayCircleFilled
import androidx.compose.material.icons.rounded.ReceiptLong
import androidx.compose.material.icons.rounded.Restaurant
import androidx.compose.material.icons.rounded.Savings
import androidx.compose.material.icons.rounded.School
import androidx.compose.material.icons.rounded.ShoppingBag
import androidx.compose.material.icons.rounded.SwapHoriz
import androidx.compose.material.icons.rounded.TrendingUp
import androidx.compose.ui.graphics.vector.ImageVector

// port of TransactionVisualResolver.mapIconName from expense_category_helpers.dart
@Suppress("DEPRECATION")
fun mapIconName(name: String?, fallback: ImageVector = Icons.Rounded.ReceiptLong): ImageVector =
    when (name?.lowercase()) {
        "utensils", "restaurant", "fastfood" -> Icons.Rounded.Restaurant
        "car", "directions_car" -> Icons.Rounded.DirectionsCar
        "shopping_bag", "shopping_cart" -> Icons.Rounded.ShoppingBag
        "receipt", "receipt_long" -> Icons.Rounded.ReceiptLong
        "film", "movie", "play" -> Icons.Rounded.PlayCircleFilled
        "music", "music_note" -> Icons.Rounded.MusicNote
        "heart_pulse", "favorite" -> Icons.Rounded.Favorite
        "graduation_cap", "school" -> Icons.Rounded.School
        "banknote", "account_balance_wallet", "wallet" -> Icons.Rounded.AccountBalanceWallet
        "sparkles", "auto_awesome" -> Icons.Rounded.AutoAwesome
        "trending_up" -> Icons.Rounded.TrendingUp
        "repeat", "swap_horiz" -> Icons.Rounded.SwapHoriz
        "savings" -> Icons.Rounded.Savings
        "flag" -> Icons.Rounded.Flag
        else -> fallback
    }
