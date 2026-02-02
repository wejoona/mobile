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
      debugPrint('[ImageQualityChecker] Skipping strict quality checks (simulator mode)');
      return ImageQualityResult.acceptable();
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return ImageQualityResult.blurry();
      }

      // Check brightness (too dark)
      if (_isTooDark(image)) {
        return ImageQualityResult.tooDark();
      }

      // Check for blur (basic check using edge detection)
      if (_isBlurry(image)) {
        return ImageQualityResult.blurry();
      }

      // Check for glare (bright spots)
      if (_hasGlare(image)) {
        return ImageQualityResult.glare();
      }

      return ImageQualityResult.acceptable();
    } catch (e) {
      // In debug mode, accept images even if quality check fails
      if (kDebugMode) {
        debugPrint('[ImageQualityChecker] Error checking quality: $e - accepting in debug mode');
        return ImageQualityResult.acceptable();
      }
      return ImageQualityResult.blurry();
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
    return avgBrightness < 40; // Threshold for too dark
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
    return avgVariance < 10; // Threshold for blur
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
    return glarePercentage > 15; // More than 15% very bright pixels
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
