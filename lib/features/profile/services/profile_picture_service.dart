import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
        preferredCameraDevice: CameraDevice.front,
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
  /// Returns the avatar as base64 string (stocké en DB, pas dans le bucket S3)
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
        '/user/avatar',
        data: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
          _logger.debug('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      // Le backend retourne avatarBase64 (stocké en DB) ou avatarUrl (legacy)
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('avatarBase64')) {
        final avatarBase64 = data['avatarBase64'] as String;
        _logger.info('Avatar uploaded successfully (base64 from DB)');
        return avatarBase64;
      }

      // Fallback: si le backend retourne encore une URL, convertir localement en base64
      if (data.containsKey('avatarUrl')) {
        _logger.warn('Backend returned avatarUrl instead of avatarBase64, converting locally');
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return base64String;
      }

      throw Exception('No avatar data in response');
    } catch (e) {
      _logger.error('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete current avatar
  Future<void> deleteAvatar() async {
    try {
      _logger.info('Deleting avatar');
      await _dio.delete('/user/avatar');
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
