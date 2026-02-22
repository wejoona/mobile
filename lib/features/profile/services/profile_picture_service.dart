import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  /// Compress image to max size (in bytes).
  /// Uses flutter_image_compress for real compression.
  /// Target: max 500KB, 80% quality, max 1024px dimension.
  Future<File> compressImage(File file, {int maxSizeBytes = 500 * 1024}) async {
    final fileSize = await file.length();

    if (fileSize <= maxSizeBytes) {
      _logger.info('Image size OK: $fileSize bytes');
      return file;
    }

    _logger.info('Compressing image: $fileSize bytes -> target $maxSizeBytes bytes');

    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        _logger.warn('Compression returned null, using original');
        return file;
      }

      // If still too large, try lower quality
      if (result.length > maxSizeBytes) {
        _logger.info('Still ${result.length} bytes, retrying at 60% quality');
        final retry = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: 800,
          minHeight: 800,
          quality: 60,
          format: CompressFormat.jpeg,
        );
        if (retry != null && retry.length < result.length) {
          final outPath = '${file.parent.path}/compressed_${file.path.split('/').last}';
          final outFile = File(outPath)..writeAsBytesSync(retry);
          _logger.info('Compressed to ${retry.length} bytes');
          return outFile;
        }
      }

      final outPath = '${file.parent.path}/compressed_${file.path.split('/').last}';
      final outFile = File(outPath)..writeAsBytesSync(result);
      _logger.info('Compressed to ${result.length} bytes');
      return outFile;
    } catch (e) {
      _logger.error('Compression failed: $e, using original');
      return file;
    }
  }
}
