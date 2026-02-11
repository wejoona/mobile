import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:usdc_wallet/core/image_cache/image_cache_config.dart';

/// Preload images for better UX
/// Use for critical images that will be displayed soon (e.g., next screen)
class ImagePreloader {
  ImagePreloader._();

  /// Preload a single image
  static Future<void> preloadImage({
    required BuildContext context,
    required String imageUrl,
    required ImageCacheType cacheType,
  }) async {
    if (imageUrl.isEmpty) return;

    final cacheManager = ImageCacheConfig.getManager(cacheType);

    try {
      await precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          cacheManager: cacheManager,
        ),
        context,
      );
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Failed to preload image: $imageUrl - $e');
    }
  }

  /// Preload multiple images in parallel
  static Future<void> preloadImages({
    required BuildContext context,
    required List<String> imageUrls,
    required ImageCacheType cacheType,
  }) async {
    final futures = imageUrls
        .where((url) => url.isNotEmpty)
        .map((url) => preloadImage(
              context: context,
              imageUrl: url,
              cacheType: cacheType,
            ))
        .toList();

    await Future.wait(futures);
  }

  /// Preload profile photos for contacts list
  /// Typically called when entering contacts/send flow
  static Future<void> preloadProfilePhotos({
    required BuildContext context,
    required List<String> photoUrls,
  }) async {
    await preloadImages(
      context: context,
      imageUrls: photoUrls,
      cacheType: ImageCacheType.profilePhoto,
    );
  }

  /// Preload bank logos for bank selection screen
  static Future<void> preloadBankLogos({
    required BuildContext context,
    required List<String> logoUrls,
  }) async {
    await preloadImages(
      context: context,
      imageUrls: logoUrls,
      cacheType: ImageCacheType.bankLogo,
    );
  }

  /// Preload merchant logos for merchants list
  static Future<void> preloadMerchantLogos({
    required BuildContext context,
    required List<String> logoUrls,
  }) async {
    await preloadImages(
      context: context,
      imageUrls: logoUrls,
      cacheType: ImageCacheType.merchantLogo,
    );
  }

  /// Check if image is already cached
  static Future<bool> isImageCached({
    required String imageUrl,
    required ImageCacheType cacheType,
  }) async {
    if (imageUrl.isEmpty) return false;

    final cacheManager = ImageCacheConfig.getManager(cacheType);
    final fileInfo = await cacheManager.getFileFromCache(imageUrl);
    return fileInfo != null && fileInfo.file.existsSync();
  }

  /// Remove specific image from cache
  static Future<void> removeFromCache({
    required String imageUrl,
    required ImageCacheType cacheType,
  }) async {
    if (imageUrl.isEmpty) return;

    final cacheManager = ImageCacheConfig.getManager(cacheType);
    await cacheManager.removeFile(imageUrl);
  }

  /// Force refresh image (remove from cache and re-download)
  static Future<void> refreshImage({
    required BuildContext context,
    required String imageUrl,
    required ImageCacheType cacheType,
  }) async {
    await removeFromCache(imageUrl: imageUrl, cacheType: cacheType);
    await preloadImage(
      context: context,
      imageUrl: imageUrl,
      cacheType: cacheType,
    );
  }
}
