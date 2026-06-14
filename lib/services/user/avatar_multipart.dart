import 'dart:io';

import 'package:dio/dio.dart';

const avatarDeviceFaceCheckField = 'deviceFaceCheck';
const avatarDeviceFaceCheckToken = 'single_face_device_v1';

class AvatarDeviceFaceCheck {
  const AvatarDeviceFaceCheck._();

  factory AvatarDeviceFaceCheck.fromDeviceAnalysis({
    required bool isAvailable,
    required int faceCount,
  }) {
    if (!isAvailable) {
      throw ArgumentError('Device face detection is unavailable');
    }
    if (faceCount != 1) {
      throw ArgumentError('Avatar upload requires exactly one detected face');
    }
    return const AvatarDeviceFaceCheck._();
  }

  String get token => avatarDeviceFaceCheckToken;
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
