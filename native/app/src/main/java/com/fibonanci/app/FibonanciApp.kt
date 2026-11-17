package com.fibonanci.app

import android.app.Application
import com.fibonanci.app.core.notification.NotificationBridge
import com.fibonanci.app.core.reminders.LocalNotificationService
import com.fibonanci.app.data.FinanceRepository
import com.fibonanci.app.data.db.AppDatabase

class FibonanciApp : Application() {
    lateinit var repository: FinanceRepository
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this
        repository = FinanceRepository(AppDatabase.open(this))
        repository.onAllowedPackagesChanged = { NotificationBridge.syncAllowedPackages(this, repository) }
        LocalNotificationService.initialize(this)
    }

    companion object {
        lateinit var instance: FibonanciApp
            private set
    }
}
