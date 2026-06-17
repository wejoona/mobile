import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Profile Picture Service
///
/// Handles local profile picture preparation only.
/// Network writes are owned by UserService through ProfileNotifier.
class ProfilePictureService {
  ProfilePictureService();

  final ImagePicker _picker = ImagePicker();
  final _logger = const AppLogger('ProfilePictureService');

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      _logger.info('Image picked from camera: ${image.path}');
      return File(image.path);
    } on Object catch (e) {
      _logger.error('Error picking from camera: $e');
      rethrow;
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      _logger.info('Image picked from gallery: ${image.path}');
      return File(image.path);
    } on Object catch (e) {
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

  /// Compress image to max size (in bytes).
  /// Uses flutter_image_compress for real compression.
  /// Target: max 500KB, 80% quality, max 1024px dimension.
  Future<File> compressImage(
    File file, {
    int maxSizeBytes = 500 * 1024,
  }) async => _compressImage(
    file,
    maxSizeBytes: maxSizeBytes,
    minWidth: 1024,
    minHeight: 1024,
    firstQuality: 80,
    retryWidth: 800,
    retryHeight: 800,
    retryQuality: 60,
  );

  /// Prepare a smaller JPEG for on-device face detection on lower-end phones.
  Future<File> prepareForFaceDetection(File file) async => _compressImage(
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
    } on Object catch (e) {
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

final profilePictureServiceProvider = Provider<ProfilePictureService>(
  (ref) => ProfilePictureService(),
);
