import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../utils/logger.dart';

/// Profile Picture Service
///
/// Handles profile picture operations:
/// - Pick from camera/gallery
/// - Upload to backend
/// - Delete avatar
class ProfilePictureService {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio;
  final _logger = AppLogger('ProfilePictureService');

  ProfilePictureService(this._dio);

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      _logger.info('Image picked from camera: ${image.path}');
      return File(image.path);
    } catch (e) {
      _logger.error('Error picking from camera: $e');
      rethrow;
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      _logger.info('Image picked from gallery: ${image.path}');
      return File(image.path);
    } catch (e) {
      _logger.error('Error picking from gallery: $e');
      rethrow;
    }
  }

  /// Upload avatar to backend
  /// Returns the avatar URL
  Future<String> uploadAvatar(File imageFile, {
    required void Function(double) onProgress,
  }) async {
    try {
      _logger.info('Uploading avatar: ${imageFile.path}');

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/v1/user/avatar',
        data: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
          _logger.debug('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      final avatarUrl = response.data['avatarUrl'] as String;
      _logger.info('Avatar uploaded successfully: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      _logger.error('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete current avatar
  Future<void> deleteAvatar() async {
    try {
      _logger.info('Deleting avatar');
      await _dio.delete('/api/v1/user/avatar');
      _logger.info('Avatar deleted successfully');
    } catch (e) {
      _logger.error('Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Compress image to max size (in bytes)
  /// Note: Basic compression is done by image_picker via imageQuality
  /// For advanced compression, we'd need flutter_image_compress package
  Future<File> compressImage(File file, {int maxSizeBytes = 500 * 1024}) async {
    final fileSize = await file.length();

    if (fileSize <= maxSizeBytes) {
      _logger.info('Image size OK: ${fileSize} bytes');
      return file;
    }

    // If we need more compression, we'd use flutter_image_compress here
    // For now, rely on image_picker's imageQuality parameter
    _logger.warn('Image size: $fileSize bytes (exceeds $maxSizeBytes). Using picker compression.');
    return file;
  }
}
