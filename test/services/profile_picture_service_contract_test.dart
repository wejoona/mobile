import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/profile/services/profile_picture_service.dart';

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

      final result = await service.uploadAvatar(file, onProgress: (_) {});

      expect(dio.requestHistory.single.path, '/user/avatar');
      expect(result.avatarUrl, '/user/avatar/usr_profile_picture');
      expect(result.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(result.message, 'Avatar uploaded successfully');
    });
  });
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
