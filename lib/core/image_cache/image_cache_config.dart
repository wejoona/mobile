import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache configuration for different image types
/// Optimized for West African network conditions (slower 3G/4G)
class ImageCacheConfig {
  // Private constructor to prevent instantiation
  ImageCacheConfig._();

  /// Profile photos cache
  /// - Long-lived (7 days) - rarely change
  /// - High quality needed for user recognition
  /// - Moderate size limit (100 MB)
  static CacheManager get profilePhotos => _profilePhotosCacheManager;

  static final CacheManager _profilePhotosCacheManager = CacheManager(
    Config(
      'profile_photos_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200, // Support ~200 contacts
      repo: JsonCacheInfoRepository(databaseName: 'profile_photos_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// Bank logos cache
  /// - Very long-lived (30 days) - static assets
  /// - Small files, high reuse
  /// - Small size limit (20 MB)
  static CacheManager get bankLogos => _bankLogosCacheManager;

  static final CacheManager _bankLogosCacheManager = CacheManager(
    Config(
      'bank_logos_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 50, // Limited number of banks
      repo: JsonCacheInfoRepository(databaseName: 'bank_logos_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// QR codes cache
  /// - Short-lived (1 hour) - dynamic content
  /// - Can be regenerated easily
  /// - Small size limit (10 MB)
  static CacheManager get qrCodes => _qrCodesCacheManager;

  static final CacheManager _qrCodesCacheManager = CacheManager(
    Config(
      'qr_codes_cache',
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: 'qr_codes_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// Merchant logos cache
  /// - Medium-lived (14 days) - semi-static
  /// - Moderate size limit (50 MB)
  static CacheManager get merchantLogos => _merchantLogosCacheManager;

  static final CacheManager _merchantLogosCacheManager = CacheManager(
    Config(
      'merchant_logos_cache',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: 'merchant_logos_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// Transaction receipts/screenshots cache
  /// - Short-lived (3 days) - temporary
  /// - Small size limit (30 MB)
  static CacheManager get receipts => _receiptsCacheManager;

  static final CacheManager _receiptsCacheManager = CacheManager(
    Config(
      'receipts_cache',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 50,
      repo: JsonCacheInfoRepository(databaseName: 'receipts_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// KYC documents cache
  /// - Medium-lived (7 days) - verification flow
  /// - Higher quality needed
  /// - Moderate size limit (100 MB)
  static CacheManager get kycDocuments => _kycDocumentsCacheManager;

  static final CacheManager _kycDocumentsCacheManager = CacheManager(
    Config(
      'kyc_documents_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 30,
      repo: JsonCacheInfoRepository(databaseName: 'kyc_documents_cache'),
      fileService: HttpFileService(),
    ),
  );

  /// Clear all image caches
  /// Useful for logout, debugging, or storage management
  static Future<void> clearAllCaches() async {
    await Future.wait([
      _profilePhotosCacheManager.emptyCache(),
      _bankLogosCacheManager.emptyCache(),
      _qrCodesCacheManager.emptyCache(),
      _merchantLogosCacheManager.emptyCache(),
      _receiptsCacheManager.emptyCache(),
      _kycDocumentsCacheManager.emptyCache(),
    ]);
  }

  /// Clear specific cache type
  static Future<void> clearCache(ImageCacheType type) async {
    switch (type) {
      case ImageCacheType.profilePhoto:
        await _profilePhotosCacheManager.emptyCache();
        break;
      case ImageCacheType.bankLogo:
        await _bankLogosCacheManager.emptyCache();
        break;
      case ImageCacheType.qrCode:
        await _qrCodesCacheManager.emptyCache();
        break;
      case ImageCacheType.merchantLogo:
        await _merchantLogosCacheManager.emptyCache();
        break;
      case ImageCacheType.receipt:
        await _receiptsCacheManager.emptyCache();
        break;
      case ImageCacheType.kycDocument:
        await _kycDocumentsCacheManager.emptyCache();
        break;
    }
  }

  /// Get cache manager for type
  static CacheManager getManager(ImageCacheType type) {
    switch (type) {
      case ImageCacheType.profilePhoto:
        return _profilePhotosCacheManager;
      case ImageCacheType.bankLogo:
        return _bankLogosCacheManager;
      case ImageCacheType.qrCode:
        return _qrCodesCacheManager;
      case ImageCacheType.merchantLogo:
        return _merchantLogosCacheManager;
      case ImageCacheType.receipt:
        return _receiptsCacheManager;
      case ImageCacheType.kycDocument:
        return _kycDocumentsCacheManager;
    }
  }

  /// Get total cache size across all types
  static Future<int> getTotalCacheSize() async {
    int totalSize = 0;
    final managers = [
      _profilePhotosCacheManager,
      _bankLogosCacheManager,
      _qrCodesCacheManager,
      _merchantLogosCacheManager,
      _receiptsCacheManager,
      _kycDocumentsCacheManager,
    ];

    for (final manager in managers) {
      final files = await manager.getFileFromCache('');
      if (files != null && files.file.existsSync()) {
        totalSize += files.file.lengthSync();
      }
    }

    return totalSize;
  }
}

/// Image cache types
enum ImageCacheType {
  profilePhoto,
  bankLogo,
  qrCode,
  merchantLogo,
  receipt,
  kycDocument,
}
