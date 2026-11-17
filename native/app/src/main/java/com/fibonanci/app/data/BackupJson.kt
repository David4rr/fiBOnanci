package com.fibonanci.app.data

import com.fibonanci.app.data.db.CategoryEntry
import com.fibonanci.app.data.db.PocketEntry
import com.fibonanci.app.data.db.ProfileEntry
import com.fibonanci.app.data.db.SubscriptionEntry
import com.fibonanci.app.data.db.TransactionEntry
import com.fibonanci.app.data.db.WalletEntry
import org.json.JSONObject

// json backup uses the same field names as the flutter app's drift data classes, dates as epoch millis.

private fun JSONObject.stringOrNull(key: String): String? = if (isNull(key)) null else getString(key)
private fun JSONObject.doubleOrNull(key: String): Double? = if (isNull(key)) null else getDouble(key)
private fun JSONObject.longOrNull(key: String): Long? = if (isNull(key)) null else getLong(key)
private fun JSONObject.intOrNull(key: String): Int? = if (isNull(key)) null else getInt(key)

// org.json drops null values on put, so nulls are written explicitly
private fun JSONObject.putNullable(key: String, value: Any?): JSONObject = put(key, value ?: JSONObject.NULL)

private fun JSONObject.putSyncMeta(id: String, createdAt: Long, updatedAt: Long, isSynced: Boolean, isDeleted: Boolean) =
    put("id", id).put("createdAt", createdAt).put("updatedAt", updatedAt).put("isSynced", isSynced).put("isDeleted", isDeleted)

fun ProfileEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .put("username", username)
    .put("fullName", fullName)
    .putNullable("email", email)
    .putNullable("phone", phone)
    .putNullable("avatarPath", avatarPath)
    .putNullable("occupation", occupation)
    .putNullable("bio", bio)
    .put("currency", currency)
    .putNullable("monthlyIncomeTarget", monthlyIncomeTarget)
    .put("isActive", isActive)

fun profileFromJson(json: JSONObject) = ProfileEntry(
    id = json.getString("id"),
    username = json.getString("username"),
    fullName = json.getString("fullName"),
    email = json.stringOrNull("email"),
    phone = json.stringOrNull("phone"),
    avatarPath = json.stringOrNull("avatarPath"),
    occupation = json.stringOrNull("occupation"),
    bio = json.stringOrNull("bio"),
    currency = json.getString("currency"),
    monthlyIncomeTarget = json.doubleOrNull("monthlyIncomeTarget"),
    isActive = json.getBoolean("isActive"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)

fun WalletEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .putNullable("profileId", profileId)
    .put("name", name)
    .put("type", type)
    .put("currency", currency)
    .put("balance", balance)
    .put("colorHex", colorHex)
    .put("iconName", iconName)
    .putNullable("accountNumber", accountNumber)

fun walletFromJson(json: JSONObject) = WalletEntry(
    id = json.getString("id"),
    profileId = json.stringOrNull("profileId"),
    name = json.getString("name"),
    type = json.getString("type"),
    currency = json.getString("currency"),
    balance = json.getDouble("balance"),
    colorHex = json.getString("colorHex"),
    iconName = json.getString("iconName"),
    accountNumber = json.stringOrNull("accountNumber"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)

fun CategoryEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .put("name", name)
    .put("type", type)
    .put("iconName", iconName)
    .put("colorHex", colorHex)

fun categoryFromJson(json: JSONObject) = CategoryEntry(
    id = json.getString("id"),
    name = json.getString("name"),
    type = json.getString("type"),
    iconName = json.getString("iconName"),
    colorHex = json.getString("colorHex"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)

fun TransactionEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .putNullable("profileId", profileId)
    .put("walletId", walletId)
    .put("categoryId", categoryId)
    .put("amount", amount)
    .put("type", type)
    .putNullable("destinationWalletId", destinationWalletId)
    .putNullable("notes", notes)
    .put("transactionDate", transactionDate)
    .put("source", source)
    .putNullable("externalRef", externalRef)

fun transactionFromJson(json: JSONObject) = TransactionEntry(
    id = json.getString("id"),
    profileId = json.stringOrNull("profileId"),
    walletId = json.getString("walletId"),
    categoryId = json.getString("categoryId"),
    amount = json.getDouble("amount"),
    type = json.getString("type"),
    destinationWalletId = json.stringOrNull("destinationWalletId"),
    notes = json.stringOrNull("notes"),
    transactionDate = json.getLong("transactionDate"),
    source = json.getString("source"),
    externalRef = json.stringOrNull("externalRef"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)

fun SubscriptionEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .putNullable("profileId", profileId)
    .put("walletId", walletId)
    .put("categoryId", categoryId)
    .put("title", title)
    .put("cost", cost)
    .put("billingCycle", billingCycle)
    .put("dueDay", dueDay)
    .put("autoDeduct", autoDeduct)
    .put("status", status)
    .putNullable("lastPaidDate", lastPaidDate)
    .put("isInstallment", isInstallment)
    .putNullable("totalCycles", totalCycles)
    .put("paidCycles", paidCycles)
    .putNullable("deadlineDate", deadlineDate)

fun subscriptionFromJson(json: JSONObject) = SubscriptionEntry(
    id = json.getString("id"),
    profileId = json.stringOrNull("profileId"),
    walletId = json.getString("walletId"),
    categoryId = json.getString("categoryId"),
    title = json.getString("title"),
    cost = json.getDouble("cost"),
    billingCycle = json.getString("billingCycle"),
    dueDay = json.getInt("dueDay"),
    autoDeduct = json.getBoolean("autoDeduct"),
    status = json.getString("status"),
    lastPaidDate = json.longOrNull("lastPaidDate"),
    isInstallment = json.getBoolean("isInstallment"),
    totalCycles = json.intOrNull("totalCycles"),
    paidCycles = json.getInt("paidCycles"),
    deadlineDate = json.longOrNull("deadlineDate"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)

fun PocketEntry.toJson(): JSONObject = JSONObject()
    .putSyncMeta(id, createdAt, updatedAt, isSynced, isDeleted)
    .putNullable("profileId", profileId)
    .put("name", name)
    .put("type", type)
    .putNullable("targetAmount", targetAmount)
    .put("currentAmount", currentAmount)
    .put("colorHex", colorHex)
    .put("iconName", iconName)
    .putNullable("targetDate", targetDate)
    .putNullable("linkedWalletId", linkedWalletId)
    .putNullable("notes", notes)

fun pocketFromJson(json: JSONObject) = PocketEntry(
    id = json.getString("id"),
    profileId = json.stringOrNull("profileId"),
    name = json.getString("name"),
    type = json.getString("type"),
    targetAmount = json.doubleOrNull("targetAmount"),
    currentAmount = json.getDouble("currentAmount"),
    colorHex = json.getString("colorHex"),
    iconName = json.getString("iconName"),
    targetDate = json.longOrNull("targetDate"),
    linkedWalletId = json.stringOrNull("linkedWalletId"),
    notes = json.stringOrNull("notes"),
    createdAt = json.getLong("createdAt"),
    updatedAt = json.getLong("updatedAt"),
    isSynced = json.getBoolean("isSynced"),
    isDeleted = json.getBoolean("isDeleted"),
)
