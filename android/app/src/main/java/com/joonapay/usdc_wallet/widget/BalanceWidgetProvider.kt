package com.joonapay.usdc_wallet.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.joonapay.usdc_wallet.R
import java.text.NumberFormat
import java.util.Locale

/**
 * JoonaPay Balance Widget Provider
 *
 * Displays wallet balance and quick action buttons
 * Supports 2x1 (small) and 4x1 (medium) widget sizes
 */
class BalanceWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widget instances
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // First widget added
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        // Last widget removed
        super.onDisabled(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_UPDATE_WIDGET -> {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, BalanceWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = loadWidgetData(context)

        // Get widget options to determine size
        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)

        // Choose layout based on width
        val layoutId = if (minWidth >= 250) {
            R.layout.widget_balance_medium
        } else {
            R.layout.widget_balance_small
        }

        val views = RemoteViews(context.packageName, layoutId)

        // Set balance
        views.setTextViewText(R.id.widget_balance, widgetData.formattedBalance)

        // Set user name or label
        val label = widgetData.userName ?: "Your Balance"
        views.setTextViewText(R.id.widget_label, label)

        // Set tap intent to open app
        val appIntent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("joonapay://home")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val appPendingIntent = PendingIntent.getActivity(
            context,
            0,
            appIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, appPendingIntent)

        // For medium widget, set quick action buttons
        if (layoutId == R.layout.widget_balance_medium) {
            // Send button
            val sendIntent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("joonapay://send")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val sendPendingIntent = PendingIntent.getActivity(
                context,
                1,
                sendIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_send_button, sendPendingIntent)

            // Receive button
            val receiveIntent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("joonapay://receive")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val receivePendingIntent = PendingIntent.getActivity(
                context,
                2,
                receiveIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_receive_button, receivePendingIntent)
        }

        // Update widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun loadWidgetData(context: Context): WidgetData {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val balance = prefs.getFloat("widget_balance", 0f).toDouble()
        val currency = prefs.getString("widget_currency", "USD") ?: "USD"
        val userName = prefs.getString("widget_user_name", null)

        return WidgetData(balance, currency, userName)
    }

    companion object {
        const val ACTION_UPDATE_WIDGET = "com.joonapay.usdc_wallet.UPDATE_WIDGET"
        private const val PREFS_NAME = "FlutterSharedPreferences"

        /**
         * Request widget update from Flutter app
         */
        fun updateWidgets(context: Context) {
            val intent = Intent(context, BalanceWidgetProvider::class.java).apply {
                action = ACTION_UPDATE_WIDGET
            }
            context.sendBroadcast(intent)
        }
    }
}

/**
 * Widget data model
 */
data class WidgetData(
    val balance: Double,
    val currency: String,
    val userName: String?
) {
    val formattedBalance: String
        get() {
            return if (currency == "XOF") {
                val formatter = NumberFormat.getNumberInstance(Locale.FRANCE)
                formatter.maximumFractionDigits = 0
                "XOF ${formatter.format(balance)}"
            } else {
                String.format(Locale.US, "$%.2f", balance)
            }
        }
}
