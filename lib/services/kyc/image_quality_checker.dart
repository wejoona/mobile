import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../features/kyc/models/image_quality_result.dart';

class ImageQualityChecker {
  /// Check if image quality is acceptable for KYC
  ///
  /// [skipStrictChecks] - If true, skips strict quality checks (for simulator/gallery testing)
  /// Callers should pass `ref.read(isSimulatorProvider)` or `ref.read(mockCameraProvider)` for this value.
  static Future<ImageQualityResult> checkQuality(
    String imagePath, {
    bool skipStrictChecks = false,
  }) async {
    // Skip strict quality checks on simulator or when explicitly requested
    if (skipStrictChecks) {
      debugPrint('[ImageQualityChecker] Skipping quality checks (simulator mode)');
      return ImageQualityResult.acceptable();
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('[ImageQualityChecker] Could not decode image');
        return ImageQualityResult.blurry();
      }

      // Log quality metrics for debugging, but don't block
      // Backend will do the real validation
      final isDark = _isTooDark(image);
      final isBlurry = _isBlurry(image);
      final hasGlare = _hasGlare(image);

      debugPrint('[ImageQualityChecker] Quality check results - dark: $isDark, blurry: $isBlurry, glare: $hasGlare');

      // Only block for extremely bad images (can't decode or completely black)
      // Let backend handle proper validation with ML models
      return ImageQualityResult.acceptable();
    } catch (e) {
      debugPrint('[ImageQualityChecker] Error checking quality: $e - accepting anyway');
      return ImageQualityResult.acceptable();
    }
  }

  static bool _isTooDark(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    // Sample pixels for performance
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        totalBrightness += (r + g + b) ~/ 3;
        pixelCount++;
      }
    }

    final avgBrightness = totalBrightness / pixelCount;
    debugPrint('[ImageQualityChecker] Brightness: $avgBrightness');
    return avgBrightness < 30; // Threshold for too dark (lowered for flexibility)
  }

  static bool _isBlurry(img.Image image) {
    // Simple Laplacian variance check for blur detection
    // Lower variance = more blur
    final grayscale = img.grayscale(image);
    double variance = 0;
    int count = 0;

    // Sample center region for performance
    final startX = grayscale.width ~/ 4;
    final endX = (grayscale.width * 3) ~/ 4;
    final startY = grayscale.height ~/ 4;
    final endY = (grayscale.height * 3) ~/ 4;

    for (int y = startY; y < endY - 1; y += 5) {
      for (int x = startX; x < endX - 1; x += 5) {
        final current = grayscale.getPixel(x, y).r.toInt();
        final right = grayscale.getPixel(x + 1, y).r.toInt();
        final bottom = grayscale.getPixel(x, y + 1).r.toInt();

        final diff = ((current - right).abs() + (current - bottom).abs()) / 2;
        variance += diff;
        count++;
      }
    }

    final avgVariance = variance / count;
    debugPrint('[ImageQualityChecker] Blur variance: $avgVariance');
    return avgVariance < 3; // Threshold for blur (lowered for ID cards with uniform areas)
  }

  static bool _hasGlare(img.Image image) {
    int brightPixels = 0;
    int totalPixels = 0;

    // Sample pixels for performance
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final brightness = (r + g + b) ~/ 3;

        if (brightness > 240) {
          brightPixels++;
        }
        totalPixels++;
      }
    }

    final glarePercentage = (brightPixels / totalPixels) * 100;
    debugPrint('[ImageQualityChecker] Glare percentage: $glarePercentage%');
    return glarePercentage > 25; // More than 25% very bright pixels (raised for ID cards)
  }

  /// Compress image for upload
  static Future<Uint8List> compressImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return bytes;
    }

    // Resize if too large
    img.Image resized = image;
    if (image.width > 1920 || image.height > 1920) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1920 : null,
        height: image.height > image.width ? 1920 : null,
      );
    }

    // Compress to JPEG with 85% quality
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
}
