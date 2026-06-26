import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/kyc_profile.dart';
import 'package:usdc_wallet/features/kyc/models/document_type.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_document.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_tier.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notification_feed;
import 'package:usdc_wallet/services/kyc/kyc_service.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart' as kyc_machine;
import 'package:usdc_wallet/state/user_state_machine.dart';

/// KYC profile provider — wired to KycService.
final kycProfileProvider = FutureProvider<KycProfile>((ref) async {
  final service = ref.watch(kycServiceProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  final data = await service.getKycStatus(forceRefresh: true);
  TransactionLimits? limits;
  try {
    limits = await ref.read(limitsServiceProvider).getLimits();
  } catch (_) {
    limits = null;
  }

  return KycProfile(
    userId: '',
    level: _levelFromStatusAndLimits(data.status, limits),
    status: data.status,
    rejectionReason: data.rejectionReason,
    submittedAt: data.submittedAt,
    verifiedAt: data.approvedAt,
  );
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

KycLevel _levelFromStatusAndLimits(
  KycStatus status,
  TransactionLimits? limits,
) {
  if (limits != null) {
    switch (limits.kycTier) {
      case 1:
        return KycLevel.basic;
      case 2:
        return KycLevel.standard;
      case 3:
        return KycLevel.premium;
      default:
        return KycLevel.none;
    }
  }

  return status.isVerified ? KycLevel.standard : KycLevel.none;
}

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
  final String? livenessProofId;
  final bool kycConsentAccepted;
  final String? returnIntent;
  final String? returnTo;

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
    this.livenessProofId,
    this.kycConsentAccepted = false,
    this.returnIntent,
    this.returnTo,
  });

  bool get hasRequiredPersonalInfo {
    final requiredFields = [
      'firstName',
      'lastName',
      'dateOfBirth',
      'country',
      'documentNumber',
    ];
    return requiredFields.every(
      (field) => (personalInfo[field]?.trim().isNotEmpty ?? false),
    );
  }

  bool get hasIdentityEvidenceForLiveness =>
      selectedDocumentType != null &&
      capturedDocuments.isNotEmpty &&
      selfiePath != null &&
      hasRequiredPersonalInfo;

  bool get hasCompletedLiveness => livenessProofId?.trim().isNotEmpty ?? false;

  bool get canEnterReview =>
      hasIdentityEvidenceForLiveness && hasCompletedLiveness;

  bool get canSubmitForManualReview =>
      hasIdentityEvidenceForLiveness && kycConsentAccepted;

  bool get canSubmit => canEnterReview && kycConsentAccepted;

  bool get canStartVerification => status.canSubmit;

  KycStatus get status => verificationStatus ?? KycStatus.none;

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
    String? livenessProofId,
    bool clearLivenessProof = false,
    bool clearVerificationStatus = false,
    bool? kycConsentAccepted,
    String? returnIntent,
    String? returnTo,
  }) => KycFlowState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
    capturedDocuments: capturedDocuments ?? this.capturedDocuments,
    selfiePath: selfiePath ?? this.selfiePath,
    verificationStatus: clearVerificationStatus
        ? null
        : verificationStatus ?? this.verificationStatus,
    rejectionReason: clearVerificationStatus
        ? null
        : rejectionReason ?? this.rejectionReason,
    targetTier: targetTier ?? this.targetTier,
    personalInfo: personalInfo ?? this.personalInfo,
    livenessProofId: clearLivenessProof
        ? null
        : livenessProofId ?? this.livenessProofId,
    kycConsentAccepted: kycConsentAccepted ?? this.kycConsentAccepted,
    returnIntent: returnIntent ?? this.returnIntent,
    returnTo: returnTo ?? this.returnTo,
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
    state = state.copyWith(
      selectedDocumentType: type,
      clearLivenessProof: true,
    );
  }

  void setPersonalInfo(Map<String, String> info) {
    state = state.copyWith(personalInfo: info, clearLivenessProof: true);
  }

  void setSelfie(String path) {
    state = state.copyWith(selfiePath: path, clearLivenessProof: true);
  }

  void setLivenessProof(String proofId) {
    state = state.copyWith(livenessProofId: proofId);
  }

  void setKycConsentAccepted({required bool accepted}) {
    state = state.copyWith(kycConsentAccepted: accepted, error: null);
  }

  void addDocument(KycDocument document) {
    state = state.copyWith(
      capturedDocuments: [...state.capturedDocuments, document],
      clearLivenessProof: true,
    );
  }

  void resetFlow() {
    state = const KycFlowState();
  }

  void startFlowForIntent({String? intent, String? returnTo}) {
    state = KycFlowState(returnIntent: intent, returnTo: returnTo);
  }

  Future<void> loadVerificationStatus() async {
    final previousStatus = state.verificationStatus;
    ref.invalidate(kycProfileProvider);
    state = state.copyWith(isLoading: true, clearVerificationStatus: true);
    try {
      final service = ref.read(kycServiceProvider);
      final data = await service.getKycStatus(forceRefresh: true);
      if (!ref.mounted) return;
      final profile = KycProfile.fromJson({
        'status': data.status.toApiString(),
        'rejectionReason': data.rejectionReason,
      });
      ref
          .read(kyc_machine.kycStateMachineProvider.notifier)
          .updateFromAuthResponse(data.status.toApiString());
      ref
          .read(userStateMachineProvider.notifier)
          .updateProfile(kycStatus: data.status);
      state = state.copyWith(
        isLoading: false,
        verificationStatus: _mapStatus(profile),
        rejectionReason: data.rejectionReason,
      );
      _refreshNotificationFeedIfStatusChanged(previousStatus, data.status);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: _friendlyKycError(e));
    }
  }

  Future<void> submitKyc({bool requireLivenessProof = true}) async {
    final canSubmit = requireLivenessProof
        ? state.canSubmit
        : state.canSubmitForManualReview;
    if (!canSubmit) {
      state = state.copyWith(
        error: requireLivenessProof
            ? 'Complete your personal information, ID document, selfie, liveness check, and KYC consent before submitting.'
            : 'Complete your personal information, ID document, selfie, and KYC consent before manual review.',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.trackKycStarted();
    try {
      final service = ref.read(kycServiceProvider);
      await service.grantRequiredKycConsents();
      // Include documents and selfie — not just personalInfo
      final documentPaths = state.capturedDocuments
          .map((doc) => doc.imagePath)
          .where((path) => path.isNotEmpty)
          .toList();
      await service.submitKyc(
        firstName: state.personalInfo['firstName'] ?? '',
        lastName: state.personalInfo['lastName'] ?? '',
        country: state.personalInfo['country'] ?? '',
        dateOfBirth:
            DateTime.tryParse(state.personalInfo['dateOfBirth'] ?? '') ??
            DateTime(2000, 1, 1),
        documentType:
            state.selectedDocumentType?.toApiString() ??
            state.personalInfo['documentType'] ??
            '',
        documentPaths: documentPaths,
        selfiePath: state.selfiePath ?? '',
        idNumber: state.personalInfo['documentNumber'],
      );
      if (!ref.mounted) return;
      await _refreshBackendStatusAfterSubmission(service);
      analytics.trackKycCompleted(success: true);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: _friendlyKycError(e));
      analytics.trackKycCompleted(success: false);
    }
  }

  Future<void> submitAddressVerification(Map<String, String> address) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitAddressVerification(
        addressLine1: address['addressLine1'] ?? '',
        addressLine2: address['addressLine2'] ?? '',
        city: address['city'] ?? '',
        state: address['state'] ?? '',
        postalCode: address['postalCode'] ?? '',
        country: address['country'] ?? '',
        documentType: address['documentType'] ?? '',
        documentPath: address['documentPath'] ?? '',
      );
      if (!ref.mounted) return;
      await _refreshBackendStatusAfterSubmission(service);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: _friendlyKycError(e));
    }
  }

  Future<void> submitAdditionalDocuments({
    required String occupation,
    required String employer,
    required String monthlyIncome,
    required String sourceOfFunds,
    required String sourceDetails,
    required List<String> paths,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitAdditionalDocuments(
        occupation: occupation,
        employer: employer,
        monthlyIncome: monthlyIncome,
        sourceOfFunds: sourceOfFunds,
        sourceDetails: sourceDetails,
        supportingDocuments: paths,
      );
      if (!ref.mounted) return;
      await _refreshBackendStatusAfterSubmission(service);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: _friendlyKycError(e));
    }
  }

  Future<void> submitDocumentForVerification() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      await service.submitKycFromData(data: state.personalInfo);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: _friendlyKycError(e));
    }
  }

  KycStatus _mapStatus(KycProfile profile) {
    if (profile.isVerified) return KycStatus.verified;
    if (profile.isRejected) return KycStatus.rejected;
    if (profile.isExpired)
      return KycStatus.none; // Expired → needs re-submission
    if (profile.status == KycStatus.manualReview) return KycStatus.manualReview;
    if (profile.status == KycStatus.submitted) return KycStatus.submitted;
    if (profile.status == KycStatus.additionalInfoNeeded)
      return KycStatus.additionalInfoNeeded;
    if (profile.status == KycStatus.documentsPending)
      return KycStatus.documentsPending;
    return profile.status;
  }

  Future<void> _refreshBackendStatusAfterSubmission(KycService service) async {
    final previousStatus = state.verificationStatus;
    final data = await service.getKycStatus(forceRefresh: true);
    if (!ref.mounted) return;

    state = state.copyWith(
      isLoading: false,
      verificationStatus: data.status,
      rejectionReason: data.rejectionReason,
    );
    _refreshNotificationFeedIfStatusChanged(previousStatus, data.status);
    ref
        .read(kyc_machine.kycStateMachineProvider.notifier)
        .updateFromAuthResponse(data.status.toApiString());
  }

  void _refreshNotificationFeedIfStatusChanged(
    KycStatus? previousStatus,
    KycStatus latestStatus,
  ) {
    if (previousStatus == latestStatus) {
      return;
    }

    ref
      ..invalidate(notification_feed.notificationsProvider)
      ..invalidate(notification_feed.unreadNotificationCountProvider);
  }
}

String _friendlyKycError(Object error) {
  if (error is DioException) {
    return ApiException.fromDioError(error).message;
  }
  if (error is ApiException) {
    return error.message;
  }
  if (error is ArgumentError) {
    return error.message?.toString() ??
        'Please complete the required verification details.';
  }
  return 'Verification could not be submitted. Please try again.';
}

/// Main KYC flow provider.
final kycProvider = NotifierProvider<KycFlowNotifier, KycFlowState>(
  KycFlowNotifier.new,
);
