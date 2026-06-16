import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const avatarDeviceFaceCheckField = 'deviceFaceCheck';
const avatarDeviceFaceCheckToken = 'single_face_device_v1';
const avatarDeviceFaceCheckVersion = 2;

class AvatarDeviceFaceCheck {
  const AvatarDeviceFaceCheck._({
    required this.isAvailable,
    required this.faceCount,
    required this.checkedAt,
  });

  final bool isAvailable;
  final int faceCount;
  final DateTime checkedAt;

  factory AvatarDeviceFaceCheck.fromDeviceAnalysis({
    required bool isAvailable,
    required int faceCount,
    DateTime? checkedAt,
  }) {
    if (!isAvailable) {
      throw ArgumentError('Device face detection is unavailable');
    }
    if (faceCount != 1) {
      throw ArgumentError('Avatar upload requires exactly one detected face');
    }
    return AvatarDeviceFaceCheck._(
      isAvailable: isAvailable,
      faceCount: faceCount,
      checkedAt: checkedAt ?? DateTime.now().toUtc(),
    );
  }

  String get token => jsonEncode({
    'version': avatarDeviceFaceCheckVersion,
    'result': avatarDeviceFaceCheckToken,
    'isAvailable': isAvailable,
    'faceCount': faceCount,
    'checkedAt': checkedAt.toUtc().toIso8601String(),
  });
}

DioMediaType avatarContentTypeForPath(String path) {
  final extension = path.split('.').last.toLowerCase();
  return switch (extension) {
    'png' => DioMediaType('image', 'png'),
    'webp' => DioMediaType('image', 'webp'),
    'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
    _ => DioMediaType('image', 'jpeg'),
  };
}

Future<MultipartFile> avatarMultipartFile(File file, {String? filename}) async {
  final effectiveFilename = filename ?? file.path.split('/').last;
  return MultipartFile.fromFile(
    file.path,
    filename: effectiveFilename,
    contentType: avatarContentTypeForPath(effectiveFilename),
  );
}
