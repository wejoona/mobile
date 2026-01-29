package com.joonapay.usdc_wallet

import android.content.Context
import com.joonapay.usdc_wallet.widget.BalanceWidgetProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel for widget communication
 */
class WidgetMethodChannel(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "com.joonapay.usdc_wallet/widget"
    )

    init {
        setupMethodHandler()
    }

    private fun setupMethodHandler() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    updateWidget()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateWidget() {
        BalanceWidgetProvider.updateWidgets(context)
    }
}
