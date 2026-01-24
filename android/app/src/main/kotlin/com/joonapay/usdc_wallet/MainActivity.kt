package com.joonapay.usdc_wallet

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// SECURITY: Play Integrity API for device attestation
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.joonapay.usdc_wallet/attestation"
    private val SECURITY_CHANNEL = "com.joonapay.usdc_wallet/security"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // SECURITY: Prevent screenshots and screen recording by default
        // This protects sensitive financial data from being captured
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // SECURITY: Method channel to control screenshot protection from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureMode" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(true)
                }
                "disableSecureMode" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIntegrityToken" -> {
                    val nonce = call.argument<String>("nonce")
                    if (nonce != null) {
                        requestIntegrityToken(nonce, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Nonce is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestIntegrityToken(nonce: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val integrityManager = IntegrityManagerFactory.create(applicationContext)

                // Build the request with nonce
                val integrityTokenRequest = IntegrityTokenRequest.builder()
                    .setNonce(nonce)
                    // Cloud project number is configured in Play Console
                    // .setCloudProjectNumber(YOUR_CLOUD_PROJECT_NUMBER)
                    .build()

                // Request the integrity token
                val integrityTokenResponse = integrityManager
                    .requestIntegrityToken(integrityTokenRequest)
                    .await()

                val token = integrityTokenResponse.token()

                // Token should be sent to your backend for verification
                // The backend decrypts and validates the token using Google's API
                val response = hashMapOf(
                    "token" to token,
                    // Note: The actual verdict is encrypted in the token
                    // and must be decrypted on your backend
                    "deviceRecognitionVerdict" to "PENDING_BACKEND_VERIFICATION"
                )

                result.success(response)
            } catch (e: Exception) {
                result.error(
                    "INTEGRITY_ERROR",
                    "Failed to get integrity token: ${e.message}",
                    e.stackTraceToString()
                )
            }
        }
    }
}
