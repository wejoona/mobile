import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// KYC profile provider — wired to KycService.
final kycProfileProvider = FutureProvider<KycProfile>((ref) async {
  final service = ref.watch(kycServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

  final data = await service.getKycStatus();
  return KycProfile.fromJson(data);
});

/// Whether KYC is verified.
final isKycVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(kycProfileProvider).valueOrNull?.isVerified ?? false;
});

/// KYC level for limit display.
final kycLevelProvider = Provider<KycLevel>((ref) {
  return ref.watch(kycProfileProvider).valueOrNull?.level ?? KycLevel.none;
});

/// KYC actions delegate.
final kycActionsProvider = Provider((ref) => ref.watch(kycServiceProvider));
