import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FaceDetectionResult {
  const FaceDetectionResult({
    required this.faceCount,
    this.isAvailable = true,
    this.message,
  });

  final int faceCount;
  final bool isAvailable;
  final String? message;

  bool get hasExactlyOneFace => faceCount == 1;
}

class ImageAnalysisService {
  static const MethodChannel _channel = MethodChannel(
    'com.joonapay.usdc_wallet/image_analysis',
  );

  Future<FaceDetectionResult> detectFaces(File imageFile) async {
    try {
      final result = await _channel
          .invokeMapMethod<String, Object?>('detectFaces', {
            'path': imageFile.path,
          })
          .timeout(const Duration(seconds: 8));
      return FaceDetectionResult(
        faceCount: (result?['faceCount'] as num?)?.toInt() ?? 0,
        isAvailable: result?['available'] as bool? ?? true,
        message: result?['message'] as String?,
      );
    } on TimeoutException {
      return const FaceDetectionResult(
        faceCount: 0,
        isAvailable: false,
        message:
            'Face check timed out. Try a brighter, smaller selfie and keep your face centered.',
      );
    } on MissingPluginException {
      return const FaceDetectionResult(
        faceCount: 0,
        isAvailable: false,
        message: 'Face detection is unavailable on this device.',
      );
    } on PlatformException catch (error) {
      return FaceDetectionResult(
        faceCount: 0,
        isAvailable: false,
        message: error.message,
      );
    }
  }
}

final imageAnalysisServiceProvider = Provider<ImageAnalysisService>(
  (_) => ImageAnalysisService(),
);
