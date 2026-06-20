import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';

void main() {
  test('StepUpDecision preserves manual-review next-action contract', () {
    final decision = StepUpDecision.fromJson({
      'flow': 'red',
      'riskScore': 95,
      'riskLevel': 'critical',
      'stepUpRequired': true,
      'stepUpType': 'manual_review',
      'reason': 'Account recovery requires manual review',
      'factors': ['new_device'],
      'challengeToken': null,
      'expiresAt': '2026-06-20T12:00:00.000Z',
      'supportReviewRequired': true,
      'nextAction': 'stage_pin_reset_manual_review',
      'nextEndpoint': '/api/v1/user/pin/reset/manual-review',
      'requiresPendingPinReset': true,
      'reviewSla': {
        'label':
            'Expected first response within 15 minutes; target resolution within 4 hours.',
        'firstResponseMinutes': 15,
        'resolutionMinutes': 240,
        'manualReview': true,
      },
    });

    expect(decision.stepUpType, StepUpType.manualReview);
    expect(decision.supportReviewRequired, isTrue);
    expect(decision.nextAction, 'stage_pin_reset_manual_review');
    expect(decision.nextEndpoint, '/api/v1/user/pin/reset/manual-review');
    expect(decision.requiresPendingPinReset, isTrue);
    expect(decision.reviewSla?.label, contains('15 minutes'));
    expect(decision.reviewSla?.firstResponseMinutes, 15);
    expect(decision.reviewSla?.resolutionMinutes, 240);
    expect(decision.reviewSla?.manualReview, isTrue);
  });
}
