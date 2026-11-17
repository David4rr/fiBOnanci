package com.fibonanci.app.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.fibonanci.app.core.security.SecurityVault
import net.zetetic.database.sqlcipher.SupportOpenHelperFactory

@Database(
    entities = [
        WalletEntry::class,
        CategoryEntry::class,
        TransactionEntry::class,
        SubscriptionEntry::class,
        NotificationRuleEntry::class,
        PocketEntry::class,
        ProfileEntry::class,
    ],
    version = 6,
    exportSchema = false,
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun dao(): FinanceDao

    // true only on the run that created the file, so the repository knows to seed it
    var wasJustCreated = false
        private set

    companion object {
        const val FILE_NAME = "fibonanci.sqlite"

        // the file is sqlcipher-encrypted with a key kept in the android keystore vault
        fun open(context: Context): AppDatabase {
            System.loadLibrary("sqlcipher")
            val key = SecurityVault.getOrCreateDatabaseKey(context)
            lateinit var db: AppDatabase
            db = Room.databaseBuilder(context, AppDatabase::class.java, FILE_NAME)
                .openHelperFactory(SupportOpenHelperFactory(key.toByteArray()))
                .addCallback(object : Callback() {
                    override fun onCreate(connection: SupportSQLiteDatabase) {
                        db.wasJustCreated = true
                    }
                })
                .build()
            return db
        }
    }
}
