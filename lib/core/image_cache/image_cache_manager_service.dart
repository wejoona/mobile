import 'dart:io' as io;

import 'package:usdc_wallet/core/image_cache/image_cache_config.dart';

/// Service for managing image caches
/// Provides statistics, cleanup, and management features
class ImageCacheManagerService {
  ImageCacheManagerService._();

  /// Get cache statistics for all types
  static Future<Map<ImageCacheType, CacheStats>> getCacheStats() async {
    final stats = <ImageCacheType, CacheStats>{};

    for (final type in ImageCacheType.values) {
      stats[type] = await _getCacheStatsForType(type);
    }

    return stats;
  }

  /// Get cache stats for specific type
  static Future<CacheStats> _getCacheStatsForType(ImageCacheType type) async {
    final manager = ImageCacheConfig.getManager(type);

    // Get all cached files
    final files = await manager.getFileFromCache('');

    int fileCount = 0;
    int totalSize = 0;

    if (files != null && files.file.existsSync()) {
      final directory = files.file.parent;
      final allFiles = directory.listSync();

      fileCount = allFiles.length;
      for (final entity in allFiles) {
        final ioFile = io.File(entity.path);
        if (ioFile.existsSync()) {
          totalSize += ioFile.lengthSync();
        }
      }
    }

    return CacheStats(
      type: type,
      fileCount: fileCount,
      totalSizeBytes: totalSize,
    );
  }

  /// Clear old/stale entries across all caches
  static Future<void> cleanupStaleCaches() async {
    final futures = ImageCacheType.values.map((type) {
      final manager = ImageCacheConfig.getManager(type);
      // This will remove stale entries based on stalePeriod
      return manager.emptyCache();
    });

    await Future.wait(futures);
  }

  /// Clear caches if total size exceeds limit (in MB)
  static Future<void> clearIfExceedsSize(int maxSizeMB) async {
    final stats = await getCacheStats();
    final totalSize = stats.values.fold<int>(
      0,
      (sum, stat) => sum + stat.totalSizeBytes,
    );

    final maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (totalSize > maxSizeBytes) {
      // Clear caches in order of importance (least important first)
      await ImageCacheConfig.clearCache(ImageCacheType.qrCode);
      await ImageCacheConfig.clearCache(ImageCacheType.receipt);

      // Check again
      final newStats = await getCacheStats();
      final newTotalSize = newStats.values.fold<int>(
        0,
        (sum, stat) => sum + stat.totalSizeBytes,
      );

      if (newTotalSize > maxSizeBytes) {
        // Still too large, clear more
        await ImageCacheConfig.clearCache(ImageCacheType.merchantLogo);
        await ImageCacheConfig.clearCache(ImageCacheType.kycDocument);
      }
    }
  }

  /// Get human-readable cache size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get cache info for debugging/settings screen
  static Future<String> getCacheInfoString() async {
    final stats = await getCacheStats();
    final buffer = StringBuffer();

    buffer.writeln('Image Cache Statistics:');
    buffer.writeln('');

    int totalFiles = 0;
    int totalSize = 0;

    for (final entry in stats.entries) {
      final type = entry.key;
      final stat = entry.value;

      buffer.writeln('${_getCacheTypeName(type)}:');
      buffer.writeln('  Files: ${stat.fileCount}');
      buffer.writeln('  Size: ${formatBytes(stat.totalSizeBytes)}');
      buffer.writeln('');

      totalFiles += stat.fileCount;
      totalSize += stat.totalSizeBytes;
    }

    buffer.writeln('Total:');
    buffer.writeln('  Files: $totalFiles');
    buffer.writeln('  Size: ${formatBytes(totalSize)}');

    return buffer.toString();
  }

  static String _getCacheTypeName(ImageCacheType type) {
    switch (type) {
      case ImageCacheType.profilePhoto:
        return 'Profile Photos';
      case ImageCacheType.bankLogo:
        return 'Bank Logos';
      case ImageCacheType.qrCode:
        return 'QR Codes';
      case ImageCacheType.merchantLogo:
        return 'Merchant Logos';
      case ImageCacheType.receipt:
        return 'Receipts';
      case ImageCacheType.kycDocument:
        return 'KYC Documents';
    }
  }
}

/// Cache statistics for a specific type
class CacheStats {
  final ImageCacheType type;
  final int fileCount;
  final int totalSizeBytes;

  const CacheStats({
    required this.type,
    required this.fileCount,
    required this.totalSizeBytes,
  });

  /// Get size in megabytes
  double get totalSizeMB => totalSizeBytes / (1024 * 1024);
}
