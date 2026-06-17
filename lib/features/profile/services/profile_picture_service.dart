import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
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

  /// Recover an image selected before Android killed the activity under memory pressure.
  Future<File?> retrieveLostImage() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return null;
      }

      if (response.exception != null) {
        throw response.exception!;
      }

      final files = response.files;
      final image = files != null && files.isNotEmpty
          ? files.first
          : response.file;
      if (image == null) {
        return null;
      }

      _logger.info('Recovered lost profile image: ${image.path}');
      return File(image.path);
    } on Object catch (e) {
      _logger.error('Error recovering lost profile image: $e');
      rethrow;
    }
  }

  /// Upload avatar to backend.
  Future<AvatarUploadResult> uploadAvatar(
    File imageFile, {
    required void Function(double) onProgress,
    required AvatarDeviceFaceCheck faceCheck,
  }) async {
    try {
      _logger.info('Uploading avatar: ${imageFile.path}');

      final fileName = imageFile.path.split('/').last;
      final boundFaceCheck = await faceCheck.bindToFile(imageFile);
      final formData = FormData.fromMap({
        avatarDeviceFaceCheckField: boundFaceCheck.token,
        'avatar': await avatarMultipartFile(imageFile, filename: fileName),
      });

      final response = await _dio.post(
        '/user/avatar',
        data: formData,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress(progress);
          _logger.debug(
            'Upload progress: ${(progress * 100).toStringAsFixed(1)}%',
          );
        },
      );

      final data = _readPayload(response.data);
      _logger.info('Avatar uploaded successfully');
      return AvatarUploadResult.fromJson(data);
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
    return _compressImage(
      file,
      maxSizeBytes: maxSizeBytes,
      minWidth: 1024,
      minHeight: 1024,
      firstQuality: 80,
      retryWidth: 800,
      retryHeight: 800,
      retryQuality: 60,
    );
  }

  /// Prepare a smaller JPEG for on-device face detection on lower-end phones.
  Future<File> prepareForFaceDetection(File file) async {
    return _compressImage(
      file,
      maxSizeBytes: 220 * 1024,
      minWidth: 720,
      minHeight: 720,
      firstQuality: 68,
      retryWidth: 560,
      retryHeight: 560,
      retryQuality: 54,
      outputPrefix: 'face_check',
      forceJpeg: true,
    );
  }

  Future<File> _compressImage(
    File file, {
    required int maxSizeBytes,
    required int minWidth,
    required int minHeight,
    required int firstQuality,
    required int retryWidth,
    required int retryHeight,
    required int retryQuality,
    String outputPrefix = 'compressed',
    bool forceJpeg = false,
  }) async {
    final fileSize = await file.length();
    final shouldConvertToJpeg =
        forceJpeg || !_hasUploadFriendlyExtension(file.path);

    if (fileSize <= maxSizeBytes && !shouldConvertToJpeg) {
      _logger.info('Image size OK: $fileSize bytes');
      return file;
    }

    _logger.info(
      'Preparing image: $fileSize bytes -> target $maxSizeBytes bytes',
    );

    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: firstQuality,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        _logger.warn('Compression returned null, using original');
        return file;
      }

      // If still too large, try lower quality
      if (result.length > maxSizeBytes) {
        _logger.info(
          'Still ${result.length} bytes, retrying at $retryQuality% quality',
        );
        final retry = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: retryWidth,
          minHeight: retryHeight,
          quality: retryQuality,
          format: CompressFormat.jpeg,
        );
        if (retry != null && retry.length < result.length) {
          final outPath = _compressedJpegPath(file, prefix: outputPrefix);
          final outFile = File(outPath)..writeAsBytesSync(retry);
          _logger.info('Compressed to ${retry.length} bytes');
          return outFile;
        }
      }

      final outPath = _compressedJpegPath(file, prefix: outputPrefix);
      final outFile = File(outPath)..writeAsBytesSync(result);
      _logger.info('Compressed to ${result.length} bytes');
      return outFile;
    } catch (e) {
      _logger.error('Compression failed: $e, using original');
      return file;
    }
  }

  bool _hasUploadFriendlyExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'webp';
  }

  String _compressedJpegPath(File file, {required String prefix}) {
    final name = file.uri.pathSegments.last;
    final dotIndex = name.lastIndexOf('.');
    final baseName = dotIndex > 0 ? name.substring(0, dotIndex) : name;
    return '${file.parent.path}/${prefix}_$baseName.jpg';
  }
}

final profilePictureServiceProvider = Provider<ProfilePictureService>((ref) {
  return ProfilePictureService(ref.watch(dioProvider));
});

Map<String, dynamic> _readPayload(Object? raw) {
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) {
      return _unwrapKnownPayload(Map<String, dynamic>.from(data));
    }
    return _unwrapKnownPayload(map);
  }
  return const {};
}

Map<String, dynamic> _unwrapKnownPayload(Map<String, dynamic> map) {
  for (final key in const ['user', 'profile', 'avatar']) {
    final nested = map[key];
    if (nested is Map) {
      return {...map, ...Map<String, dynamic>.from(nested)};
    }
  }
  return map;
}
