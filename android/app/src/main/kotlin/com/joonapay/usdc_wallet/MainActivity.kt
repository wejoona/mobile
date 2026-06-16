package com.joonapay.usdc_wallet

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.FaceDetector
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import android.view.WindowManager
import androidx.biometric.BiometricManager
import androidx.exifinterface.media.ExifInterface
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
import kotlinx.coroutines.withContext
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.joonapay.usdc_wallet/attestation"
    private val SECURITY_CHANNEL = "com.joonapay.usdc_wallet/security"
    private val BIOMETRICS_CHANNEL = "com.joonapay.usdc_wallet/biometrics"
    private val IMAGE_ANALYSIS_CHANNEL = "com.joonapay.usdc_wallet/image_analysis"
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGE_ANALYSIS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "detectFaces" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "Image path is required", null)
                    } else {
                        detectFaces(path, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun detectFaces(path: String, result: MethodChannel.Result) {
        if (!File(path).exists()) {
            result.error("FILE_NOT_FOUND", "Image file was not found", null)
            return
        }

        CoroutineScope(Dispatchers.Default).launch {
            try {
                val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(path, bounds)
                if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
                    withContext(Dispatchers.Main) {
                        result.error("IMAGE_LOAD_FAILED", "Unable to read the selected image", null)
                    }
                    return@launch
                }

                var sampleSize = 1
                while (bounds.outWidth / sampleSize > 1024 || bounds.outHeight / sampleSize > 1024) {
                    sampleSize *= 2
                }

                val decoded = BitmapFactory.decodeFile(
                    path,
                    BitmapFactory.Options().apply {
                        inSampleSize = sampleSize
                        inPreferredConfig = Bitmap.Config.RGB_565
                    }
                )

                if (decoded == null) {
                    withContext(Dispatchers.Main) {
                        result.error("IMAGE_LOAD_FAILED", "Unable to read the selected image", null)
                    }
                    return@launch
                }

                val oriented = orientBitmapForFaceDetection(path, decoded)
                val rgb565 = if (oriented.config == Bitmap.Config.RGB_565) {
                    oriented
                } else {
                    oriented.copy(Bitmap.Config.RGB_565, false) ?: oriented
                }

                if (rgb565.width < 2 || rgb565.height < 2) {
                    withContext(Dispatchers.Main) {
                        result.success(
                            hashMapOf(
                                "available" to true,
                                "faceCount" to 0
                            )
                        )
                    }
                    return@launch
                }

                val analysisBitmap = if (rgb565.width % 2 == 0) {
                    rgb565
                } else {
                    Bitmap.createBitmap(rgb565, 0, 0, rgb565.width - 1, rgb565.height)
                }

                val maxFaces = 8
                val faces = arrayOfNulls<FaceDetector.Face>(maxFaces)
                val faceCount = FaceDetector(
                    analysisBitmap.width,
                    analysisBitmap.height,
                    maxFaces
                ).findFaces(analysisBitmap, faces)

                withContext(Dispatchers.Main) {
                    result.success(
                        hashMapOf(
                            "available" to true,
                            "faceCount" to faceCount
                        )
                    )
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error(
                        "FACE_DETECTION_FAILED",
                        e.message ?: "Face detection failed",
                        e.stackTraceToString()
                    )
                }
            }
        }
    }

    private fun orientBitmapForFaceDetection(path: String, bitmap: Bitmap): Bitmap {
        val orientation = try {
            ExifInterface(path).getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_NORMAL
            )
        } catch (_: Exception) {
            ExifInterface.ORIENTATION_NORMAL
        }

        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.postRotate(90f)
                matrix.preScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.postRotate(270f)
                matrix.preScale(-1f, 1f)
            }
            else -> return bitmap
        }

        return try {
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        } catch (_: Exception) {
            bitmap
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
