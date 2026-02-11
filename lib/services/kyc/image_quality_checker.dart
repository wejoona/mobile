import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:usdc_wallet/features/kyc/models/image_quality_result.dart';

/// Image quality checker for KYC document validation
///
/// Designed to work across all iOS devices from iPhone 6 (8MP) to iPhone 17 Pro Max (48MP+)
/// Uses resolution normalization to ensure consistent quality detection regardless of device.
class ImageQualityChecker {
  // Analysis configuration
  static const int _analysisSize = 640; // Normalize to 640px for analysis
  static const int _minAcceptableResolution = 480; // Minimum input resolution

  // Thresholds calibrated for 640px normalized images across device range
  // These are intentionally permissive - backend ML does final validation
  static const double _darknessThreshold = 35; // Average brightness < 35 = too dark
  static const double _blurThreshold = 3.0; // Gradient < 3 = blurry (very permissive)
  static const double _glareThreshold = 25.0; // > 25% very bright pixels = glare

  /// Check if image quality is acceptable for KYC
  ///
  /// Supports all iOS devices from iPhone 6 to latest models.
  /// [skipStrictChecks] - If true, skips quality checks (for simulator/testing)
  static Future<ImageQualityResult> checkQuality(
    String imagePath, {
    bool skipStrictChecks = false,
  }) async {
    if (skipStrictChecks) {
      debugPrint('[ImageQualityChecker] Skipping checks (test mode)');
      return ImageQualityResult.acceptable();
    }

    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        debugPrint('[ImageQualityChecker] Failed to decode image');
        return ImageQualityResult.blurry();
      }

      final origWidth = originalImage.width;
      final origHeight = originalImage.height;
      debugPrint('[ImageQualityChecker] Input: ${origWidth}x$origHeight');

      // Check minimum resolution
      final minDim = math.min(origWidth, origHeight);
      if (minDim < _minAcceptableResolution) {
        debugPrint('[ImageQualityChecker] Resolution too low: $minDim < $_minAcceptableResolution');
        return ImageQualityResult.blurry();
      }

      // Normalize for consistent analysis across all devices
      final normalized = _normalizeForAnalysis(originalImage);
      debugPrint('[ImageQualityChecker] Normalized: ${normalized.width}x${normalized.height}');

      // Run quality checks on normalized image
      final brightness = _calculateBrightness(normalized);
      final gradient = _calculateGradient(normalized);
      final glare = _calculateGlare(normalized);

      debugPrint('[ImageQualityChecker] Brightness: ${brightness.toStringAsFixed(1)} (threshold: >$_darknessThreshold)');
      debugPrint('[ImageQualityChecker] Sharpness: ${gradient.toStringAsFixed(2)} (threshold: >$_blurThreshold)');
      debugPrint('[ImageQualityChecker] Glare: ${glare.toStringAsFixed(1)}% (threshold: <$_glareThreshold%)');

      // Check thresholds
      if (brightness < _darknessThreshold) {
        debugPrint('[ImageQualityChecker] FAILED: Too dark');
        return ImageQualityResult.tooDark();
      }

      if (gradient < _blurThreshold) {
        debugPrint('[ImageQualityChecker] FAILED: Too blurry');
        return ImageQualityResult.blurry();
      }

      if (glare > _glareThreshold) {
        debugPrint('[ImageQualityChecker] FAILED: Too much glare');
        return ImageQualityResult.glare();
      }

      debugPrint('[ImageQualityChecker] PASSED: Quality acceptable');
      return ImageQualityResult.acceptable();
    } catch (e, stack) {
      debugPrint('[ImageQualityChecker] Error: $e');
      debugPrint('[ImageQualityChecker] Stack: $stack');
      // Accept in debug mode to not block development
      if (kDebugMode) {
        return ImageQualityResult.acceptable();
      }
      return ImageQualityResult.blurry();
    }
  }

  /// Normalize image to standard size for device-independent analysis
  static img.Image _normalizeForAnalysis(img.Image image) {
    final maxDim = math.max(image.width, image.height);

    // Don't upscale small images
    if (maxDim <= _analysisSize) {
      return image;
    }

    // Downscale maintaining aspect ratio
    // Use linear interpolation for better quality (important for blur detection)
    if (image.width >= image.height) {
      return img.copyResize(
        image,
        width: _analysisSize,
        interpolation: img.Interpolation.linear,
      );
    } else {
      return img.copyResize(
        image,
        height: _analysisSize,
        interpolation: img.Interpolation.linear,
      );
    }
  }

  /// Calculate average brightness (0-255)
  static double _calculateBrightness(img.Image image) {
    int total = 0;
    int count = 0;

    // Sample every 4th pixel for performance
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final pixel = image.getPixel(x, y);
        // Luminance formula: 0.299*R + 0.587*G + 0.114*B
        final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).round();
        total += luminance;
        count++;
      }
    }

    return total / count;
  }

  /// Calculate average gradient magnitude (edge strength indicator)
  /// Higher values = sharper image, lower values = blurrier
  static double _calculateGradient(img.Image image) {
    final grayscale = img.grayscale(image);
    double totalGradient = 0;
    int count = 0;

    // Analyze center 60% of image (where document should be)
    final marginX = (grayscale.width * 0.2).round();
    final marginY = (grayscale.height * 0.2).round();
    final endX = grayscale.width - marginX - 1;
    final endY = grayscale.height - marginY - 1;

    // Sample every 2nd pixel for balance of accuracy and performance
    for (int y = marginY; y < endY; y += 2) {
      for (int x = marginX; x < endX; x += 2) {
        final current = grayscale.getPixel(x, y).r.toInt();
        final right = grayscale.getPixel(x + 1, y).r.toInt();
        final bottom = grayscale.getPixel(x, y + 1).r.toInt();

        // Sobel-like gradient magnitude
        final gx = (current - right).abs();
        final gy = (current - bottom).abs();
        totalGradient += math.sqrt(gx * gx + gy * gy);
        count++;
      }
    }

    return totalGradient / count;
  }

  /// Calculate percentage of very bright pixels (glare indicator)
  static double _calculateGlare(img.Image image) {
    int brightPixels = 0;
    int totalPixels = 0;

    // Sample every 4th pixel
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) ~/ 3;

        // Very bright threshold (near white)
        if (brightness > 250) {
          brightPixels++;
        }
        totalPixels++;
      }
    }

    return (brightPixels / totalPixels) * 100;
  }

  /// Compress image for upload
  /// Maintains quality while reducing file size
  static Future<Uint8List> compressImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return bytes;
    }

    // Target max dimension for upload
    const maxUploadSize = 1920;

    img.Image resized = image;
    if (image.width > maxUploadSize || image.height > maxUploadSize) {
      if (image.width >= image.height) {
        resized = img.copyResize(image, width: maxUploadSize);
      } else {
        resized = img.copyResize(image, height: maxUploadSize);
      }
    }

    // Compress to JPEG with good quality
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
}
