# SECURITY: ProGuard rules for JoonaPay USDC Wallet
# These rules enable code obfuscation to protect against reverse engineering

#-------------------------------------------
# SIZE OPTIMIZATION: General optimizations
#-------------------------------------------
# Enable optimization and obfuscation with safe settings
-optimizationpasses 3
-allowaccessmodification
-repackageclasses ''

#-------------------------------------------
# Flutter specific rules
#-------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

#-------------------------------------------
# Dio HTTP client
#-------------------------------------------
-keep class com.squareup.okhttp3.** { *; }
-keep interface com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

#-------------------------------------------
# Gson (used by various plugins)
#-------------------------------------------
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

#-------------------------------------------
# Flutter Secure Storage
#-------------------------------------------
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }

#-------------------------------------------
# Local Auth (Biometrics)
#-------------------------------------------
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }

#-------------------------------------------
# Crypto operations
#-------------------------------------------
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }

#-------------------------------------------
# Keep model classes (prevent obfuscation of data classes)
# Add your app's model packages here
#-------------------------------------------
# -keep class com.joonapay.models.** { *; }

#-------------------------------------------
# Remove logging in release builds
#-------------------------------------------
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

#-------------------------------------------
# Prevent debugging
#-------------------------------------------
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable

#-------------------------------------------
# General Android rules
#-------------------------------------------
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

-keepclassmembers class **.R$* {
    public static <fields>;
}

#-------------------------------------------
# Play Integrity API (device attestation)
#-------------------------------------------
-keep class com.google.android.play.core.integrity.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

#-------------------------------------------
# Crashlytics / Firebase (if used)
#-------------------------------------------
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

#-------------------------------------------
# SIZE OPTIMIZATION: Firebase
#-------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

#-------------------------------------------
# SIZE OPTIMIZATION: Remove verbose logging
#-------------------------------------------
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    public static void checkParameterIsNotNull(...);
    public static void checkExpressionValueIsNotNull(...);
    public static void checkNotNullExpressionValue(...);
    public static void checkReturnedValueIsNotNull(...);
    public static void checkFieldIsNotNull(...);
    public static void throwUninitializedPropertyAccessException(...);
}

#-------------------------------------------
# SIZE OPTIMIZATION: Camera plugin
#-------------------------------------------
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

#-------------------------------------------
# SIZE OPTIMIZATION: QR/Barcode scanning
#-------------------------------------------
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.android.gms.vision.**

#-------------------------------------------
# SIZE OPTIMIZATION: PDF library
#-------------------------------------------
-dontwarn org.apache.tika.**
-dontwarn javax.xml.stream.**
-dontwarn org.bouncycastle.**
-keep class org.apache.pdfbox.** { *; }
-keep class com.tom_roush.pdfbox.** { *; }

#-------------------------------------------
# SIZE OPTIMIZATION: Image processing
#-------------------------------------------
-dontwarn javax.imageio.**
-keep class com.caverock.androidsvg.** { *; }
