/// E2E: KYC liveness session contract used by PIN recovery and onboarding.
library;

import 'package:test/test.dart';

import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  late E2EClient client;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Liveness E2E', () {
    test(
      'POST /kyc/liveness/session returns photo-compatible challenges',
      () async {
        final res = await client.post('/kyc/liveness/session', {
          'capabilities': {
            'supportedCaptureModes': ['photo'],
            'preferredCaptureMode': 'photo',
            'supportedMimeTypes': ['image/jpeg'],
            'supportsOnDeviceFaceDetection': false,
            'supportsReferenceSelfie': true,
          },
        });
        res.expectOk();

        final rawBody = res.data ?? <String, dynamic>{};
        final body = rawBody['data'] is Map<String, dynamic>
            ? rawBody['data'] as Map<String, dynamic>
            : rawBody;
        expect(
          body['sessionToken'],
          isA<String>().having((v) => v, 'not empty', isNotEmpty),
          reason: 'Body: ${res.body}',
        );
        expect(body['requiredCaptureMode'], 'photo');
        expect(body['acceptedCaptureModes'], contains('photo'));

        final challenges = body['challenges'];
        expect(
          challenges,
          isA<List<dynamic>>().having((v) => v, 'not empty', isNotEmpty),
        );
        for (final raw in challenges as List<dynamic>) {
          final challenge = raw as Map<String, dynamic>;
          expect(
            challenge['challengeId'] ?? challenge['id'],
            isA<String>().having((v) => v, 'not empty', isNotEmpty),
            reason: 'Challenge: $challenge',
          );
          expect(challenge['acceptedCaptureModes'], contains('photo'));
          expect(challenge['requiredCaptureMode'], isNot('video'));
          expect(challenge['requiresMotionEvidence'], isNot(true));
        }
      },
    );
  });
}
