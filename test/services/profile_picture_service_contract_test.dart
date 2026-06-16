import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/profile/services/profile_picture_service.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';

import '../helpers/test_utils.dart';

void main() {
  group('ProfilePictureService API contract', () {
    test('unwraps standard avatar upload response envelopes', () async {
      final file = await _writeTinyJpeg();
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'avatarUrl': '/user/avatar/usr_profile_picture',
            'avatarThumb': 'data:image/jpeg;base64,/9j/thumb',
            'message': 'Avatar uploaded successfully',
          },
        });
      final service = ProfilePictureService(dio);

      final result = await service.uploadAvatar(
        file,
        onProgress: (_) {},
        faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ),
      );

      expect(dio.requestHistory.single.path, '/user/avatar');
      final formData = dio.requestHistory.single.data as FormData;
      expect(formData.files.single.key, 'avatar');
      final evidence = _decodeFaceCheckEvidence(formData);
      expect(evidence, containsPair('version', avatarDeviceFaceCheckVersion));
      expect(evidence, containsPair('result', avatarDeviceFaceCheckToken));
      expect(evidence, containsPair('isAvailable', true));
      expect(evidence, containsPair('faceCount', 1));
      expect(evidence['checkedAt'], isA<String>());
      expect(result.avatarUrl, '/user/avatar/usr_profile_picture');
      expect(result.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(result.message, 'Avatar uploaded successfully');
    });

    test('unwraps nested user avatar upload envelopes', () async {
      final file = await _writeTinyJpeg();
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'user': {
              'avatar_url': '/user/avatar/usr_nested',
              'avatarBase64': 'data:image/jpeg;base64,/9j/nested',
            },
          },
        });
      final service = ProfilePictureService(dio);

      final result = await service.uploadAvatar(
        file,
        onProgress: (_) {},
        faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ),
      );

      expect(result.avatarUrl, '/user/avatar/usr_nested');
      expect(result.avatarThumb, startsWith('data:image/jpeg;base64,'));
    });

    test('unwraps nested profile avatar upload envelopes', () async {
      final file = await _writeTinyJpeg();
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'profile': {
              'avatarUrl': '/user/avatar/usr_profile',
              'avatarThumb': 'data:image/jpeg;base64,/9j/profile',
            },
          },
        });
      final service = ProfilePictureService(dio);

      final result = await service.uploadAvatar(
        file,
        onProgress: (_) {},
        faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ),
      );

      expect(result.avatarUrl, '/user/avatar/usr_profile');
      expect(result.avatarThumb, startsWith('data:image/jpeg;base64,'));
    });
  });
}

Map<String, dynamic> _decodeFaceCheckEvidence(FormData formData) {
  final field = formData.fields.singleWhere(
    (entry) => entry.key == avatarDeviceFaceCheckField,
  );
  return jsonDecode(field.value) as Map<String, dynamic>;
}

Future<File> _writeTinyJpeg() async {
  final file = File('${Directory.systemTemp.path}/korido-profile-contract.jpg');
  await file.writeAsBytes(const [
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
    0x49,
    0x46,
    0x00,
    0x01,
    0xFF,
    0xD9,
  ]);
  return file;
}
