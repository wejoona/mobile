/// Image cache module exports
///
/// Optimized image caching for JoonaPay mobile app
/// Configured for West African network conditions
///
/// Usage:
/// ```dart
/// // Use pre-built widgets (recommended)
/// ProfilePhotoWidget(imageUrl: user.photoUrl, size: 48)
/// BankLogoWidget(imageUrl: bank.logoUrl, size: 40)
/// QRCodeWidget(imageUrl: qrCodeUrl, size: 200)
///
/// // Custom caching
/// CachedImageWidget(
///   imageUrl: imageUrl,
///   cacheType: ImageCacheType.profilePhoto,
///   width: 100,
///   height: 100,
/// )
///
/// // Preload for better UX
/// await ImagePreloader.preloadProfilePhotos(
///   context: context,
///   photoUrls: contacts.map((c) => c.photoUrl).toList(),
/// )
///
/// // Clear caches (logout, settings)
/// await ImageCacheConfig.clearAllCaches()
/// ```

export 'image_cache_config.dart';
export 'cached_image_widget.dart';
export 'image_preloader.dart';
export 'image_cache_manager_service.dart';
