package com.joonapay.usdc_wallet

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import android.view.WindowManager
import androidx.biometric.BiometricManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

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
    private val BIOMETRICS_CHANNEL = "com.joonapay.usdc_wallet/biometrics"
    private val BIOMETRIC_KEY_ALIAS = "korido_biometric_enrollment_guard"
    private val BIOMETRIC_PREFS = "korido_biometric_state"
    private val BIOMETRIC_GENERATION_KEY = "generation"

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BIOMETRICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getEnrollmentStateHash" -> getBiometricEnrollmentStateHash(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun getBiometricEnrollmentStateHash(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            result.error(
                "BIOMETRIC_UNAVAILABLE",
                "Biometric enrollment invalidation requires Android 7.0 or newer",
                null
            )
            return
        }

        val biometricManager = BiometricManager.from(this)
        val canAuthenticate = biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
        )

        if (canAuthenticate != BiometricManager.BIOMETRIC_SUCCESS) {
            result.error("BIOMETRIC_UNAVAILABLE", "Strong biometrics are not available", null)
            return
        }

        try {
            ensureBiometricGuardKey()
            validateBiometricGuardKey()
            result.success("android:${getBiometricGeneration()}")
        } catch (_: UserNotAuthenticatedException) {
            result.success("android:${getBiometricGeneration()}")
        } catch (_: KeyPermanentlyInvalidatedException) {
            incrementBiometricGeneration()
            recreateBiometricGuardKey()
            result.success("android:${getBiometricGeneration()}")
        } catch (e: Exception) {
            result.error(
                "BIOMETRIC_STATE_UNAVAILABLE",
                "Unable to read biometric enrollment state: ${e.message}",
                e.stackTraceToString()
            )
        }
    }

    private fun ensureBiometricGuardKey() {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (!keyStore.containsAlias(BIOMETRIC_KEY_ALIAS)) {
            recreateBiometricGuardKey()
        }
    }

    private fun recreateBiometricGuardKey() {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (keyStore.containsAlias(BIOMETRIC_KEY_ALIAS)) {
            keyStore.deleteEntry(BIOMETRIC_KEY_ALIAS)
        }

        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            "AndroidKeyStore"
        )

        val spec = KeyGenParameterSpec.Builder(
            BIOMETRIC_KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(true)
            .build()

        keyGenerator.init(spec)
        keyGenerator.generateKey()
    }

    private fun validateBiometricGuardKey() {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val key = keyStore.getKey(BIOMETRIC_KEY_ALIAS, null) as SecretKey
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
    }

    private fun getBiometricGeneration(): Int {
        return getSharedPreferences(BIOMETRIC_PREFS, Context.MODE_PRIVATE)
            .getInt(BIOMETRIC_GENERATION_KEY, 0)
    }

    private fun incrementBiometricGeneration() {
        val prefs = getSharedPreferences(BIOMETRIC_PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putInt(BIOMETRIC_GENERATION_KEY, prefs.getInt(BIOMETRIC_GENERATION_KEY, 0) + 1)
            .apply()
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
