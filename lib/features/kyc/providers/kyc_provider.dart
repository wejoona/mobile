import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/features/kyc/models/document_type.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_document.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_tier.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// KYC profile provider — wired to KycService.
final kycProfileProvider = FutureProvider<KycProfile>((ref) async {
  final service = ref.watch(kycServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

  final data = await service.getKycStatus();
  return KycProfile(userId: '', level: KycLevel.none, status: data.status, rejectionReason: data.rejectionReason);
});

/// Whether KYC is verified.
final isKycVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(kycProfileProvider).value?.isVerified ?? false;
});

/// KYC level for limit display.
final kycLevelProvider = Provider<KycLevel>((ref) {
  return ref.watch(kycProfileProvider).value?.level ?? KycLevel.none;
});

/// KYC actions delegate.
final kycActionsProvider = Provider((ref) => ref.watch(kycServiceProvider));

// ── KYC Flow State & Notifier ──

/// KYC flow state for the verification wizard.
class KycFlowState {
  final bool isLoading;
  final String? error;
  final DocumentType? selectedDocumentType;
  final List<KycDocument> capturedDocuments;
  final String? selfiePath;
  final KycStatus? verificationStatus;
  final String? rejectionReason;
  final KycTier? targetTier;
  final Map<String, String> personalInfo;

  const KycFlowState({
    this.isLoading = false,
    this.error,
    this.selectedDocumentType,
    this.capturedDocuments = const [],
    this.selfiePath,
    this.verificationStatus,
    this.rejectionReason,
    this.targetTier,
    this.personalInfo = const {},
  });

  bool get canSubmit =>
      selectedDocumentType != null &&
      capturedDocuments.isNotEmpty &&
      selfiePath != null &&
      personalInfo.isNotEmpty;

  bool get canStartVerification => capturedDocuments.isNotEmpty;

  KycFlowState copyWith({
    bool? isLoading,
    String? error,
    DocumentType? selectedDocumentType,
    List<KycDocument>? capturedDocuments,
    String? selfiePath,
    KycStatus? verificationStatus,
    String? rejectionReason,
    KycTier? targetTier,
    Map<String, String>? personalInfo,
  }) => KycFlowState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
    capturedDocuments: capturedDocuments ?? this.capturedDocuments,
    selfiePath: selfiePath ?? this.selfiePath,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    targetTier: targetTier ?? this.targetTier,
    personalInfo: personalInfo ?? this.personalInfo,
  );
}

/// KYC flow notifier — manages the KYC verification wizard.
class KycFlowNotifier extends Notifier<KycFlowState> {
  @override
  KycFlowState build() => const KycFlowState();

  void setTargetTier(KycTier tier) {
    state = state.copyWith(targetTier: tier);
  }

  void selectDocumentType(DocumentType type) {
    state = state.copyWith(selectedDocumentType: type);
  }

  void setPersonalInfo(Map<String, String> info) {
    state = state.copyWith(personalInfo: info);
  }

  void setSelfie(String path) {
    state = state.copyWith(selfiePath: path);
  }

  void addDocument(KycDocument document) {
    state = state.copyWith(
      capturedDocuments: [...state.capturedDocuments, document],
    );
  }

  void resetFlow() {
    state = const KycFlowState();
  }

  Future<void> loadVerificationStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      final data = await service.getKycStatus();
      final profile = KycProfile.fromJson({'status': data.status.name, 'rejectionReason': data.rejectionReason});
      state = state.copyWith(
        isLoading: false,
        verificationStatus: _mapStatus(profile),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitKyc() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitKycFromData(data: state.personalInfo);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAddressVerification(Map<String, String> address) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitKycFromData(data: address);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAdditionalDocuments(List<String> paths) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitKycFromData(data: {'additionalDocs': paths.join(',')});
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitDocumentForVerification() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitKycFromData(data: state.personalInfo);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  KycStatus _mapStatus(KycProfile profile) {
    if (profile.isVerified) return KycStatus.verified;
    return KycStatus.pending;
  }
}

/// Main KYC flow provider.
final kycProvider = NotifierProvider<KycFlowNotifier, KycFlowState>(KycFlowNotifier.new);
