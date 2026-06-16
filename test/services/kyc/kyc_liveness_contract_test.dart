import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/kyc/kyc_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('KycService liveness contract', () {
    test(
      'declares photo-only client capabilities when creating a session',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'sessionToken': 'kyc-session-1',
            'challenges': [
              {
                'id': 'smile_1',
                'type': 'SMILE',
                'instruction': 'Give a natural smile',
                'acceptedCaptureModes': ['photo'],
                'requiredCaptureMode': 'photo',
              },
            ],
            'requiredCaptureMode': 'photo',
            'acceptedCaptureModes': ['photo'],
            'requiredEvidence': ['reference_selfie', 'challenge_photo'],
            'evidencePolicy': {
              'captureModes': {
                'accepted': ['photo'],
                'required': 'photo',
              },
              'manualReviewOnProviderUnavailable': true,
            },
          });
        final service = KycService(dio);

        final session = await service.createLivenessSession();
        final request = dio.requestHistory.single;
        final data = request.data as Map<String, dynamic>;
        final capabilities = data['capabilities'] as Map<String, dynamic>;

        expect(request.method, 'POST');
        expect(request.path, '/kyc/liveness/session');
        expect(capabilities['supportedCaptureModes'], ['photo']);
        expect(capabilities['preferredCaptureMode'], 'photo');
        expect(capabilities['supportedMimeTypes'], ['image/jpeg']);
        expect(capabilities['maxVideoDurationSeconds'], isNull);
        expect(capabilities['supportsOnDeviceFaceDetection'], isFalse);
        expect(capabilities['supportsReferenceSelfie'], isTrue);
        expect(session.sessionToken, 'kyc-session-1');
        expect(session.acceptedCaptureModes, ['photo']);
        expect(session.requiredEvidence, [
          'reference_selfie',
          'challenge_photo',
        ]);
      },
    );
  });
}
