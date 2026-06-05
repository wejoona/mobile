import 'dart:io';

import 'package:dio/dio.dart';

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
