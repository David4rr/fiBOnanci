package com.fibonanci.app.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

// a null profile id means every profile
private const val PROFILE_FILTER = "(:profileId IS NULL OR profile_id = :profileId)"

@Dao
interface FinanceDao {
    // wallets
    @Query("SELECT * FROM wallets WHERE is_deleted = 0 AND $PROFILE_FILTER")
    fun watchWallets(profileId: String?): Flow<List<WalletEntry>>

    @Query("SELECT * FROM wallets WHERE is_deleted = 0 AND $PROFILE_FILTER")
    suspend fun getWallets(profileId: String?): List<WalletEntry>

    @Query("SELECT * FROM wallets WHERE id = :id")
    suspend fun getWallet(id: String): WalletEntry?

    @Insert
    suspend fun insertWallet(wallet: WalletEntry)

    @Update
    suspend fun updateWallet(wallet: WalletEntry)

    @Upsert
    suspend fun upsertWallet(wallet: WalletEntry)

    @Query("UPDATE wallets SET balance = 0, is_deleted = 1, updated_at = :now, is_synced = 0 WHERE (:wipeAll = 1 AND is_deleted = 0) OR (:wipeAll = 0 AND $PROFILE_FILTER)")
    suspend fun deleteWalletsOfProfile(profileId: String, wipeAll: Boolean, now: Long)

    @Query("UPDATE wallets SET balance = 0, updated_at = :now, is_synced = 0 WHERE is_deleted = 0 AND $PROFILE_FILTER")
    suspend fun zeroWalletBalances(profileId: String, now: Long)

    // categories
    @Query("SELECT * FROM categories WHERE is_deleted = 0")
    fun watchCategories(): Flow<List<CategoryEntry>>

    @Query("SELECT * FROM categories WHERE is_deleted = 0")
    suspend fun getCategories(): List<CategoryEntry>

    @Query("SELECT * FROM categories")
    suspend fun getAllCategories(): List<CategoryEntry>

    @Upsert
    suspend fun upsertCategory(category: CategoryEntry)

    @Query("UPDATE categories SET is_deleted = 1, updated_at = :now, is_synced = 0 WHERE id = :id")
    suspend fun softDeleteCategory(id: String, now: Long)

    // transactions
    @Query("SELECT * FROM transactions WHERE is_deleted = 0 AND $PROFILE_FILTER ORDER BY transaction_date DESC LIMIT :limit")
    fun watchTransactions(profileId: String?, limit: Int): Flow<List<TransactionEntry>>

    @Query("SELECT * FROM transactions WHERE is_deleted = 0 AND $PROFILE_FILTER ORDER BY transaction_date DESC LIMIT :limit")
    suspend fun getTransactions(profileId: String?, limit: Int): List<TransactionEntry>

    @Query("SELECT * FROM transactions WHERE is_deleted = 0")
    suspend fun getAllActiveTransactions(): List<TransactionEntry>

    @Query("SELECT * FROM transactions WHERE id = :id")
    suspend fun getTransaction(id: String): TransactionEntry?

    @Query("SELECT * FROM transactions WHERE external_ref = :ref AND is_deleted = 0")
    suspend fun getTransactionsByExternalRef(ref: String): List<TransactionEntry>

    @Insert
    suspend fun insertTransaction(tx: TransactionEntry)

    @Update
    suspend fun updateTransaction(tx: TransactionEntry)

    @Upsert
    suspend fun upsertTransaction(tx: TransactionEntry)

    @Query("UPDATE transactions SET is_deleted = 1, updated_at = :now, is_synced = 0 WHERE (:wipeAll = 1 AND is_deleted = 0) OR (:wipeAll = 0 AND $PROFILE_FILTER)")
    suspend fun deleteTransactionsOfProfile(profileId: String, wipeAll: Boolean, now: Long)

    // subscriptions
    @Query("SELECT * FROM subscriptions WHERE is_deleted = 0 AND status != 'cancelled' AND $PROFILE_FILTER ORDER BY due_day ASC")
    fun watchSubscriptions(profileId: String?): Flow<List<SubscriptionEntry>>

    @Query("SELECT * FROM subscriptions WHERE is_deleted = 0 AND status != 'cancelled' AND $PROFILE_FILTER ORDER BY due_day ASC")
    suspend fun getVisibleSubscriptions(profileId: String?): List<SubscriptionEntry>

    @Query("SELECT * FROM subscriptions WHERE is_deleted = 0 AND status = 'active' AND $PROFILE_FILTER")
    suspend fun getSubscriptions(profileId: String?): List<SubscriptionEntry>

    @Query("SELECT * FROM subscriptions WHERE is_deleted = 0 AND status = 'active' AND auto_deduct = 1")
    suspend fun getAutoDeductSubscriptions(): List<SubscriptionEntry>

    @Query("SELECT * FROM subscriptions WHERE id = :id")
    suspend fun getSubscription(id: String): SubscriptionEntry?

    @Insert
    suspend fun insertSubscription(sub: SubscriptionEntry)

    @Update
    suspend fun updateSubscription(sub: SubscriptionEntry)

    @Upsert
    suspend fun upsertSubscription(sub: SubscriptionEntry)

    @Query("UPDATE subscriptions SET is_deleted = 1, updated_at = :now, is_synced = 0 WHERE (:wipeAll = 1 AND is_deleted = 0) OR (:wipeAll = 0 AND $PROFILE_FILTER)")
    suspend fun deleteSubscriptionsOfProfile(profileId: String, wipeAll: Boolean, now: Long)

    // pockets
    @Query("SELECT * FROM pockets WHERE is_deleted = 0 AND $PROFILE_FILTER ORDER BY created_at ASC")
    fun watchPockets(profileId: String?): Flow<List<PocketEntry>>

    @Query("SELECT * FROM pockets WHERE is_deleted = 0 AND $PROFILE_FILTER ORDER BY created_at ASC")
    suspend fun getPockets(profileId: String?): List<PocketEntry>

    @Query("SELECT * FROM pockets WHERE id = :id")
    suspend fun getPocket(id: String): PocketEntry?

    @Insert
    suspend fun insertPocket(pocket: PocketEntry)

    @Update
    suspend fun updatePocket(pocket: PocketEntry)

    @Upsert
    suspend fun upsertPocket(pocket: PocketEntry)

    @Query("UPDATE pockets SET current_amount = 0, is_deleted = 1, updated_at = :now, is_synced = 0 WHERE (:wipeAll = 1 AND is_deleted = 0) OR (:wipeAll = 0 AND $PROFILE_FILTER)")
    suspend fun deletePocketsOfProfile(profileId: String, wipeAll: Boolean, now: Long)

    @Query("UPDATE pockets SET current_amount = 0, updated_at = :now, is_synced = 0 WHERE is_deleted = 0 AND $PROFILE_FILTER")
    suspend fun zeroPocketAmounts(profileId: String, now: Long)

    // profiles
    @Query("SELECT * FROM profiles WHERE is_deleted = 0 ORDER BY created_at ASC")
    fun watchProfiles(): Flow<List<ProfileEntry>>

    @Query("SELECT * FROM profiles WHERE is_deleted = 0 ORDER BY created_at ASC")
    suspend fun getProfiles(): List<ProfileEntry>

    @Query("SELECT * FROM profiles WHERE is_deleted = 0 AND is_active = 1 LIMIT 1")
    suspend fun getActiveProfile(): ProfileEntry?

    @Query("SELECT * FROM profiles WHERE id = :id")
    suspend fun getProfile(id: String): ProfileEntry?

    @Insert
    suspend fun insertProfile(profile: ProfileEntry)

    @Update
    suspend fun updateProfile(profile: ProfileEntry)

    @Upsert
    suspend fun upsertProfile(profile: ProfileEntry)

    @Query("UPDATE profiles SET is_active = 0, updated_at = :now WHERE is_deleted = 0")
    suspend fun deactivateProfiles(now: Long)

    // notification rules
    @Query("SELECT * FROM notification_rules WHERE is_deleted = 0 AND $PROFILE_FILTER ORDER BY created_at DESC")
    fun watchNotificationRules(profileId: String?): Flow<List<NotificationRuleEntry>>

    @Query("SELECT * FROM notification_rules WHERE is_deleted = 0 AND $PROFILE_FILTER")
    suspend fun getNotificationRules(profileId: String?): List<NotificationRuleEntry>

    @Query("SELECT * FROM notification_rules WHERE wallet_id = :walletId AND is_deleted = 0")
    suspend fun getNotificationRulesForWallet(walletId: String): List<NotificationRuleEntry>

    @Query("SELECT * FROM notification_rules WHERE is_enabled = 1 AND is_deleted = 0 ORDER BY updated_at DESC")
    suspend fun getEnabledNotificationRules(): List<NotificationRuleEntry>

    @Query("SELECT * FROM notification_rules WHERE package_name IN (:packages) AND is_deleted = 0 LIMIT 1")
    suspend fun getNotificationRuleForPackages(packages: List<String>): NotificationRuleEntry?

    @Insert
    suspend fun insertNotificationRule(rule: NotificationRuleEntry)

    @Update
    suspend fun updateNotificationRule(rule: NotificationRuleEntry)

    @Query("UPDATE notification_rules SET is_deleted = 1, is_enabled = 0, updated_at = :now, is_synced = 0 WHERE wallet_id = :walletId")
    suspend fun deleteNotificationRulesForWallet(walletId: String, now: Long)

    @Query("UPDATE notification_rules SET is_deleted = 1, is_enabled = 0, updated_at = :now, is_synced = 0 WHERE wallet_id = :walletId AND package_name NOT IN (:keepPackages) AND is_deleted = 0")
    suspend fun deleteOtherRulesForWallet(walletId: String, keepPackages: List<String>, now: Long)

    @Query("UPDATE notification_rules SET is_deleted = 1, is_enabled = 0, updated_at = :now, is_synced = 0 WHERE package_name IN (:packages)")
    suspend fun deleteNotificationRulesForPackages(packages: List<String>, now: Long)

    @Query("UPDATE notification_rules SET is_enabled = 0, is_deleted = 1, updated_at = :now, is_synced = 0 WHERE (:wipeAll = 1 AND is_deleted = 0) OR (:wipeAll = 0 AND $PROFILE_FILTER)")
    suspend fun deleteNotificationRulesOfProfile(profileId: String, wipeAll: Boolean, now: Long)
}
