import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';

void main() {
  group('liveness score normalization', () {
    test('normalizes provider percentages and ratios into decision ratios', () {
      expect(livenessScoreFromJson(94), 0.94);
      expect(livenessScoreFromJson(0.94), 0.94);
      expect(livenessScoreFromJson('88'), 0.88);
      expect(livenessScoreFromJson('0.88'), 0.88);
      expect(livenessScoreFromJson(null), isNull);
      expect(livenessScoreFromJson('invalid'), isNull);
    });

    test('parses final challenge result without assuming integer scores', () {
      final decimalResult = ChallengeSubmitResult.fromJson({
        'sessionToken': 'sess_123',
        'status': 'completed',
        'challengesCompleted': 2,
        'challengesTotal': 2,
        'confidence': 0.94,
        'result': {
          'isAlive': true,
          'confidence': 0.94,
          'antiSpoofScore': 0.91,
          'faceMatchScore': 0.89,
        },
      });

      expect(decimalResult.confidence, 0.94);
      expect(decimalResult.result?.confidence, 0.94);
      expect(decimalResult.result?.antiSpoofScore, 0.91);
      expect(decimalResult.result?.faceMatchScore, 0.89);

      final percentageResult = ChallengeSubmitResult.fromJson({
        'sessionToken': 'sess_456',
        'status': 'completed',
        'challengesCompleted': 2,
        'challengesTotal': 2,
        'confidence': 94,
        'result': {
          'isAlive': true,
          'confidence': 94,
          'antiSpoofScore': 91,
          'faceMatchScore': 89,
        },
      });

      expect(percentageResult.confidence, 0.94);
      expect(percentageResult.result?.confidence, 0.94);
      expect(percentageResult.result?.antiSpoofScore, 0.91);
      expect(percentageResult.result?.faceMatchScore, 0.89);
      expect(
        evaluateLivenessScore(percentageResult.result!.confidence),
        LivenessDecision.autoApprove,
      );
    });
  });
}
