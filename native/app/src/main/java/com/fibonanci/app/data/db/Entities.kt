package com.fibonanci.app.data.db

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

// all dates are epoch millis (utc). every entity carries the syncable metadata columns.

@Entity(tableName = "profiles")
data class ProfileEntry(
    @PrimaryKey val id: String,
    val username: String,
    @ColumnInfo(name = "full_name") val fullName: String,
    val email: String? = null,
    val phone: String? = null,
    @ColumnInfo(name = "avatar_path") val avatarPath: String? = null,
    val occupation: String? = null,
    val bio: String? = null,
    val currency: String = "IDR",
    @ColumnInfo(name = "monthly_income_target") val monthlyIncomeTarget: Double? = null,
    @ColumnInfo(name = "is_active") val isActive: Boolean = true,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "wallets")
data class WalletEntry(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "profile_id") val profileId: String? = null,
    val name: String,
    val type: String, // bank, ewallet, cash, investment, other
    val currency: String = "IDR",
    val balance: Double = 0.0,
    @ColumnInfo(name = "color_hex") val colorHex: String = "#10B981",
    @ColumnInfo(name = "icon_name") val iconName: String = "wallet",
    @ColumnInfo(name = "account_number") val accountNumber: String? = null,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "categories")
data class CategoryEntry(
    @PrimaryKey val id: String,
    val name: String,
    val type: String, // expense, income
    @ColumnInfo(name = "icon_name") val iconName: String = "category",
    @ColumnInfo(name = "color_hex") val colorHex: String = "#64748B",
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "transactions")
data class TransactionEntry(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "profile_id") val profileId: String? = null,
    @ColumnInfo(name = "wallet_id") val walletId: String,
    @ColumnInfo(name = "category_id") val categoryId: String,
    val amount: Double,
    val type: String, // expense, income, transfer
    @ColumnInfo(name = "destination_wallet_id") val destinationWalletId: String? = null,
    val notes: String? = null,
    @ColumnInfo(name = "transaction_date") val transactionDate: Long,
    val source: String = "manual", // manual, notification_auto, subscription_recurring
    @ColumnInfo(name = "external_ref") val externalRef: String? = null,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "subscriptions")
data class SubscriptionEntry(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "profile_id") val profileId: String? = null,
    @ColumnInfo(name = "wallet_id") val walletId: String,
    @ColumnInfo(name = "category_id") val categoryId: String,
    val title: String,
    val cost: Double,
    @ColumnInfo(name = "billing_cycle") val billingCycle: String = "monthly", // monthly, yearly, weekly
    @ColumnInfo(name = "due_day") val dueDay: Int,
    @ColumnInfo(name = "auto_deduct") val autoDeduct: Boolean = false,
    val status: String = "active", // active, completed, cancelled
    @ColumnInfo(name = "last_paid_date") val lastPaidDate: Long? = null,
    @ColumnInfo(name = "is_installment") val isInstallment: Boolean = false,
    @ColumnInfo(name = "total_cycles") val totalCycles: Int? = null,
    @ColumnInfo(name = "paid_cycles") val paidCycles: Int = 0,
    @ColumnInfo(name = "deadline_date") val deadlineDate: Long? = null,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "notification_rules")
data class NotificationRuleEntry(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "profile_id") val profileId: String? = null,
    @ColumnInfo(name = "package_name") val packageName: String,
    @ColumnInfo(name = "wallet_id") val walletId: String,
    @ColumnInfo(name = "is_enabled") val isEnabled: Boolean = true,
    @ColumnInfo(name = "auto_confirm") val autoConfirm: Boolean = false,
    @ColumnInfo(name = "default_category_id") val defaultCategoryId: String? = null,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)

@Entity(tableName = "pockets")
data class PocketEntry(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "profile_id") val profileId: String? = null,
    val name: String,
    val type: String = "savings", // emergency, retirement, savings, goal, other
    @ColumnInfo(name = "target_amount") val targetAmount: Double? = null,
    @ColumnInfo(name = "current_amount") val currentAmount: Double = 0.0,
    @ColumnInfo(name = "color_hex") val colorHex: String = "#D4F442",
    @ColumnInfo(name = "icon_name") val iconName: String = "savings",
    @ColumnInfo(name = "target_date") val targetDate: Long? = null,
    @ColumnInfo(name = "linked_wallet_id") val linkedWalletId: String? = null,
    val notes: String? = null,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    @ColumnInfo(name = "updated_at") val updatedAt: Long,
    @ColumnInfo(name = "is_synced") val isSynced: Boolean = false,
    @ColumnInfo(name = "is_deleted") val isDeleted: Boolean = false,
)
