import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../../features/kyc/models/image_quality_result.dart';

class ImageQualityChecker {
  /// Standard size for quality analysis - normalizes across all device resolutions
  static const int _analysisSize = 800;

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
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        debugPrint('[ImageQualityChecker] Could not decode image');
        return ImageQualityResult.blurry();
      }

      debugPrint('[ImageQualityChecker] Original image: ${originalImage.width}x${originalImage.height}');

      // Normalize to standard size for consistent quality analysis across all devices
      // This is critical because gradient-based blur detection is resolution-dependent
      final image = _normalizeForAnalysis(originalImage);
      debugPrint('[ImageQualityChecker] Normalized to: ${image.width}x${image.height}');

      // Check brightness (too dark)
      if (_isTooDark(image)) {
        return ImageQualityResult.tooDark();
      }

      // Check for blur (using Laplacian variance on normalized image)
      if (_isBlurry(image)) {
        return ImageQualityResult.blurry();
      }

      // Check for glare (bright spots)
      if (_hasGlare(image)) {
        return ImageQualityResult.glare();
      }

      return ImageQualityResult.acceptable();
    } catch (e) {
      debugPrint('[ImageQualityChecker] Error checking quality: $e');
      // In debug mode, accept images even if quality check fails
      if (kDebugMode) {
        debugPrint('[ImageQualityChecker] Accepting in debug mode');
        return ImageQualityResult.acceptable();
      }
      return ImageQualityResult.blurry();
    }
  }

  /// Normalize image to standard size for consistent quality analysis
  /// This ensures blur/brightness thresholds work the same on all devices
  static img.Image _normalizeForAnalysis(img.Image image) {
    final maxDimension = image.width > image.height ? image.width : image.height;

    // Only resize if larger than analysis size
    if (maxDimension <= _analysisSize) {
      return image;
    }

    // Maintain aspect ratio
    if (image.width > image.height) {
      return img.copyResize(image, width: _analysisSize);
    } else {
      return img.copyResize(image, height: _analysisSize);
    }
  }

  static bool _isTooDark(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    // Sample pixels for performance (every 5th pixel on normalized image)
    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        totalBrightness += (r + g + b) ~/ 3;
        pixelCount++;
      }
    }

    final avgBrightness = totalBrightness / pixelCount;
    debugPrint('[ImageQualityChecker] Brightness: ${avgBrightness.toStringAsFixed(1)}');
    return avgBrightness < 40; // Threshold for too dark
  }

  static bool _isBlurry(img.Image image) {
    // Laplacian variance for blur detection
    // On normalized image, thresholds are consistent across devices
    final grayscale = img.grayscale(image);
    double sumGradient = 0;
    int count = 0;

    // Sample center region (50% of image) where document should be
    final startX = grayscale.width ~/ 4;
    final endX = (grayscale.width * 3) ~/ 4;
    final startY = grayscale.height ~/ 4;
    final endY = (grayscale.height * 3) ~/ 4;

    // Calculate gradient magnitude (edge strength)
    for (int y = startY; y < endY - 1; y += 2) {
      for (int x = startX; x < endX - 1; x += 2) {
        final current = grayscale.getPixel(x, y).r.toInt();
        final right = grayscale.getPixel(x + 1, y).r.toInt();
        final bottom = grayscale.getPixel(x, y + 1).r.toInt();

        // Gradient magnitude
        final gradientX = (current - right).abs();
        final gradientY = (current - bottom).abs();
        sumGradient += (gradientX + gradientY) / 2;
        count++;
      }
    }

    final avgGradient = sumGradient / count;
    debugPrint('[ImageQualityChecker] Blur gradient: ${avgGradient.toStringAsFixed(2)}');

    // On 800px normalized image, sharp ID cards typically have gradient > 8
    // Blurry images have gradient < 5
    return avgGradient < 5;
  }

  static bool _hasGlare(img.Image image) {
    int brightPixels = 0;
    int totalPixels = 0;

    // Sample pixels for performance
    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final brightness = (r + g + b) ~/ 3;

        if (brightness > 245) {
          brightPixels++;
        }
        totalPixels++;
      }
    }

    final glarePercentage = (brightPixels / totalPixels) * 100;
    debugPrint('[ImageQualityChecker] Glare: ${glarePercentage.toStringAsFixed(1)}%');

    // More than 20% very bright pixels indicates glare
    return glarePercentage > 20;
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
