package com.joonapay.usdc_wallet.widget

import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.work.*
import java.util.concurrent.TimeUnit

/**
 * Background service to update widgets periodically
 * Uses WorkManager for battery-efficient background updates
 */
class WidgetUpdateService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Schedule periodic widget updates
        scheduleWidgetUpdates()
        return START_STICKY
    }

    private fun scheduleWidgetUpdates() {
        val constraints = Constraints.Builder()
            .setRequiresBatteryNotLow(true)
            .build()

        val updateRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
            15, TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniquePeriodicWork(
                "widget_update",
                ExistingPeriodicWorkPolicy.KEEP,
                updateRequest
            )
    }

    companion object {
        fun scheduleUpdates(context: android.content.Context) {
            val intent = Intent(context, WidgetUpdateService::class.java)
            context.startService(intent)
        }
    }
}

/**
 * Worker to update widgets in background
 */
class WidgetUpdateWorker(
    context: android.content.Context,
    params: WorkerParameters
) : Worker(context, params) {

    override fun doWork(): Result {
        return try {
            // Trigger widget update
            BalanceWidgetProvider.updateWidgets(applicationContext)
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }
}
