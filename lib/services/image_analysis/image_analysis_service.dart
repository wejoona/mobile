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
  static const _faceDetectionTimeout = Duration(seconds: 15);
  static const MethodChannel _channel = MethodChannel(
    'com.joonapay.usdc_wallet/image_analysis',
  );

  Future<FaceDetectionResult> detectFaces(File imageFile) async {
    try {
      final result = await _channel
          .invokeMapMethod<String, Object?>('detectFaces', {
            'path': imageFile.path,
          })
          .timeout(_faceDetectionTimeout);
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
            'Face check is taking too long. Try a brighter selfie with your face centered.',
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
        message: _friendlyPlatformMessage(error),
      );
    }
  }

  String _friendlyPlatformMessage(PlatformException error) {
    final rawMessage = '${error.code} ${error.message ?? ''}'.toLowerCase();

    if (rawMessage.contains('vndetect') ||
        rawMessage.contains('vision') ||
        rawMessage.contains('cancel')) {
      return 'Face check could not complete. Please try a brighter selfie with your face centered.';
    }

    if (rawMessage.contains('permission') ||
        rawMessage.contains('denied') ||
        rawMessage.contains('restricted')) {
      return 'Camera or photo permission is needed before we can check your face.';
    }

    return error.message ??
        'Face detection is unavailable right now. Please try another clear selfie.';
  }
}

final imageAnalysisServiceProvider = Provider<ImageAnalysisService>(
  (_) => ImageAnalysisService(),
);
