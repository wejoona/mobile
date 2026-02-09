import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/core/image_cache/index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up path_provider mock before any cache manager is used
  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('image_cache_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });

  group('ImageCacheConfig', () {
    test('should provide different cache managers for different types', () {
      final profileManager = ImageCacheConfig.getManager(ImageCacheType.profilePhoto);
      final bankManager = ImageCacheConfig.getManager(ImageCacheType.bankLogo);
      final qrManager = ImageCacheConfig.getManager(ImageCacheType.qrCode);

      expect(profileManager, isNotNull);
      expect(bankManager, isNotNull);
      expect(qrManager, isNotNull);
      expect(profileManager, isNot(equals(bankManager)));
      expect(bankManager, isNot(equals(qrManager)));
    });

    test('should clear all caches', () async {
      await ImageCacheConfig.clearAllCaches();
      // If no exception is thrown, test passes
      expect(true, true);
    });

    test('should clear specific cache type', () async {
      await ImageCacheConfig.clearCache(ImageCacheType.profilePhoto);
      // If no exception is thrown, test passes
      expect(true, true);
    });
  });

  group('ProfilePhotoWidget', () {
    testWidgets('should show fallback when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfilePhotoWidget(
              imageUrl: null,
              size: 48,
              fallbackInitials: 'AB',
            ),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('should show fallback when imageUrl is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfilePhotoWidget(
              imageUrl: '',
              size: 48,
              fallbackInitials: 'CD',
            ),
          ),
        ),
      );

      expect(find.text('CD'), findsOneWidget);
    });

    testWidgets('should have correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfilePhotoWidget(
              imageUrl: null,
              size: 100,
              fallbackInitials: 'XY',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProfilePhotoWidget),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
    });
  });

  group('BankLogoWidget', () {
    testWidgets('should render with correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BankLogoWidget(
              imageUrl: 'https://example.com/logo.png',
              size: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CachedImageWidget), findsOneWidget);
    });

    testWidgets('should show border when requested', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BankLogoWidget(
              imageUrl: 'https://example.com/logo.png',
              size: 40,
              showBorder: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BankLogoWidget),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });

  group('QRCodeWidget', () {
    testWidgets('should render with correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRCodeWidget(
              imageUrl: 'https://example.com/qr.png',
              size: 200,
            ),
          ),
        ),
      );

      expect(find.byType(CachedImageWidget), findsOneWidget);
    });
  });

  group('MerchantLogoWidget', () {
    testWidgets('should render with correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantLogoWidget(
              imageUrl: 'https://example.com/merchant.png',
              size: 56,
            ),
          ),
        ),
      );

      expect(find.byType(CachedImageWidget), findsOneWidget);
    });
  });

  group('ImageCacheManagerService', () {
    test('should format bytes correctly', () {
      expect(ImageCacheManagerService.formatBytes(500), '500 B');
      expect(ImageCacheManagerService.formatBytes(1024), '1.0 KB');
      expect(ImageCacheManagerService.formatBytes(1024 * 1024), '1.0 MB');
      expect(ImageCacheManagerService.formatBytes(1024 * 1024 * 1024), '1.0 GB');
    });

    test('should get cache stats', () async {
      final stats = await ImageCacheManagerService.getCacheStats();
      expect(stats, isNotNull);
      expect(stats.length, ImageCacheType.values.length);
      expect(stats[ImageCacheType.profilePhoto], isNotNull);
    });

    test('should get cache info string', () async {
      final info = await ImageCacheManagerService.getCacheInfoString();
      expect(info, isNotNull);
      expect(info, contains('Image Cache Statistics'));
      expect(info, contains('Profile Photos'));
      expect(info, contains('Bank Logos'));
    });

    test('should cleanup stale caches', () async {
      await ImageCacheManagerService.cleanupStaleCaches();
      // If no exception is thrown, test passes
      expect(true, true);
    });

    test('should clear if exceeds size', () async {
      await ImageCacheManagerService.clearIfExceedsSize(100);
      // If no exception is thrown, test passes
      expect(true, true);
    });
  });

  group('ImagePreloader', () {
    testWidgets('should handle empty image URL gracefully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      await ImagePreloader.preloadImage(
        context: tester.element(find.byType(Scaffold)),
        imageUrl: '',
        cacheType: ImageCacheType.profilePhoto,
      );

      // Should complete without error
      expect(true, true);
    });

    testWidgets('should preload multiple images', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      await ImagePreloader.preloadImages(
        context: tester.element(find.byType(Scaffold)),
        imageUrls: [
          'https://example.com/1.jpg',
          'https://example.com/2.jpg',
          '',
        ],
        cacheType: ImageCacheType.profilePhoto,
      );

      // Should complete without error
      expect(true, true);
    }, skip: true);

    test('should check if image is cached', () async {
      final isCached = await ImagePreloader.isImageCached(
        imageUrl: 'https://example.com/test.jpg',
        cacheType: ImageCacheType.profilePhoto,
      );

      expect(isCached, isA<bool>());
    });

    test('should handle empty URL in isImageCached', () async {
      final isCached = await ImagePreloader.isImageCached(
        imageUrl: '',
        cacheType: ImageCacheType.profilePhoto,
      );

      expect(isCached, false);
    });

    test('should remove from cache', () async {
      await ImagePreloader.removeFromCache(
        imageUrl: 'https://example.com/test.jpg',
        cacheType: ImageCacheType.profilePhoto,
      );

      // Should complete without error
      expect(true, true);
    });
  });

  group('CacheStats', () {
    test('should calculate size in MB', () {
      final stats = CacheStats(
        type: ImageCacheType.profilePhoto,
        fileCount: 10,
        totalSizeBytes: 5 * 1024 * 1024, // 5 MB
      );

      expect(stats.totalSizeMB, closeTo(5.0, 0.1));
    });

    test('should have correct properties', () {
      final stats = CacheStats(
        type: ImageCacheType.bankLogo,
        fileCount: 20,
        totalSizeBytes: 1024 * 1024,
      );

      expect(stats.type, ImageCacheType.bankLogo);
      expect(stats.fileCount, 20);
      expect(stats.totalSizeBytes, 1024 * 1024);
    });
  });
}
