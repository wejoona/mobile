import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kyc_status.dart';
import '../models/kyc_document.dart';
import '../models/document_type.dart';
import '../models/kyc_submission.dart';
import '../models/kyc_tier.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';
import '../../../services/kyc/kyc_service.dart';
import '../../../state/fsm/fsm_provider.dart';
import '../../../state/fsm/kyc_fsm.dart' as fsm;
import '../../profile/providers/profile_provider.dart';

class KycState {
  final KycStatus status;
  final String? rejectionReason;
  final bool isLoading;
  final String? error;
  final DocumentType? selectedDocumentType;
  final List<KycDocument> capturedDocuments;
  final String? selfiePath;
  final double uploadProgress;
  final KycTier? targetTier;
  final String? videoPath;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  // Personal info fields
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  // Verification status (from /kyc/verification/status)
  final FullVerificationStatus? verificationStatus;

  const KycState({
    this.status = KycStatus.pending,
    this.rejectionReason,
    this.isLoading = false,
    this.error,
    this.selectedDocumentType,
    this.capturedDocuments = const [],
    this.selfiePath,
    this.uploadProgress = 0.0,
    this.targetTier,
    this.videoPath,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.nationality,
    this.verificationStatus,
  });

  bool get canStartVerification => status.canSubmit;
  bool get hasDocumentType => selectedDocumentType != null;
  bool get hasAllDocuments {
    if (selectedDocumentType == null) return false;
    if (selectedDocumentType!.requiresBackSide) {
      return capturedDocuments.length == 2;
    }
    return capturedDocuments.length == 1;
  }

  bool get hasSelfie => selfiePath != null;
  bool get canSubmit => hasAllDocuments && hasSelfie;

  KycSubmission get submission => KycSubmission(
        documents: capturedDocuments,
        selfiePath: selfiePath,
      );

  bool get hasPersonalInfo =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty &&
      dateOfBirth != null;

  KycState copyWith({
    KycStatus? status,
    String? rejectionReason,
    bool? isLoading,
    String? error,
    DocumentType? selectedDocumentType,
    List<KycDocument>? capturedDocuments,
    String? selfiePath,
    double? uploadProgress,
    KycTier? targetTier,
    String? videoPath,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? nationality,
    FullVerificationStatus? verificationStatus,
  }) {
    return KycState(
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
      capturedDocuments: capturedDocuments ?? this.capturedDocuments,
      selfiePath: selfiePath ?? this.selfiePath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      targetTier: targetTier ?? this.targetTier,
      videoPath: videoPath ?? this.videoPath,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  KycState clearError() => copyWith(error: '');
  KycState resetDocuments() => copyWith(
        selectedDocumentType: null,
        capturedDocuments: [],
        selfiePath: '',
        uploadProgress: 0.0,
      );
}

class KycNotifier extends Notifier<KycState> {
  @override
  KycState build() => const KycState();

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);
      final response = await sdk.kyc.getKycStatus();
      state = state.copyWith(
        isLoading: false,
        status: response.status,
        rejectionReason: response.rejectionReason,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectDocumentType(DocumentType type) {
    state = state.copyWith(selectedDocumentType: type);
  }

  void setPersonalInfo({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    String? nationality,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      nationality: nationality,
    );
  }

  void addDocument(KycDocument document) {
    final documents = List<KycDocument>.from(state.capturedDocuments);
    documents.add(document);
    state = state.copyWith(capturedDocuments: documents);
  }

  void updateDocument(int index, KycDocument document) {
    final documents = List<KycDocument>.from(state.capturedDocuments);
    if (index >= 0 && index < documents.length) {
      documents[index] = document;
      state = state.copyWith(capturedDocuments: documents);
    }
  }

  void removeDocument(int index) {
    final documents = List<KycDocument>.from(state.capturedDocuments);
    if (index >= 0 && index < documents.length) {
      documents.removeAt(index);
      state = state.copyWith(capturedDocuments: documents);
    }
  }

  void setSelfie(String path) {
    state = state.copyWith(selfiePath: path);
  }

  void removeSelfie() {
    state = state.copyWith(selfiePath: '');
  }

  Future<void> submitKyc() async {
    if (!state.canSubmit) return;
    if (!state.hasPersonalInfo) {
      state = state.copyWith(error: 'Personal information is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: '', uploadProgress: 0.0);
    try {
      final sdk = ref.read(sdkProvider);

      final documentPaths = state.capturedDocuments
          .map((doc) => doc.imagePath)
          .toList();

      await sdk.kyc.submitKyc(
        documentPaths: documentPaths,
        selfiePath: state.selfiePath!,
        documentType: state.selectedDocumentType!.toApiString(),
        firstName: state.firstName!,
        lastName: state.lastName!,
        dateOfBirth: state.dateOfBirth!,
        country: state.nationality ?? 'CI',
      );

      state = state.copyWith(
        isLoading: false,
        status: KycStatus.submitted,
        uploadProgress: 1.0,
      );

      // Use selfie as profile picture
      if (state.selfiePath != null && state.selfiePath!.isNotEmpty) {
        try {
          final selfieFile = File(state.selfiePath!);
          if (await selfieFile.exists()) {
            await ref.read(profileProvider.notifier).updateAvatar(selfieFile);
          }
        } catch (_) {
          // Ignore avatar upload errors - KYC is still successful
        }
      }

      // Sync with FSM - update KYC state to pending (submitted, awaiting review)
      ref.read(appFsmProvider.notifier).onKycStatusLoaded(
        tier: fsm.KycTier.none,
        status: 'pending',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        uploadProgress: 0.0,
      );
    }
  }

  /// Load full verification status from /kyc/verification/status
  Future<void> loadVerificationStatus() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);
      final verificationStatus = await sdk.kyc.getVerificationStatus();
      state = state.copyWith(
        isLoading: false,
        status: verificationStatus.kyc.status,
        rejectionReason: verificationStatus.kyc.rejectionReason,
        verificationStatus: verificationStatus,
      );
    } catch (e) {
      debugPrint('[KYC] Failed to load verification status: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Submit document for VerifyHQ verification
  /// Uploads front (+ optional back) image and submits S3 keys
  Future<DocumentSubmitResponse?> submitDocumentForVerification() async {
    if (!state.hasAllDocuments) return null;

    state = state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);
      final docType = state.selectedDocumentType!.toApiString();

      // Upload front image
      final frontPath = state.capturedDocuments[0].imagePath;
      debugPrint('[KYC] Uploading front document image...');
      final frontKey = await sdk.kyc.uploadFileForVerification(frontPath, 'idFront');

      // Upload back image if present
      String? backKey;
      if (state.capturedDocuments.length > 1) {
        final backPath = state.capturedDocuments[1].imagePath;
        debugPrint('[KYC] Uploading back document image...');
        backKey = await sdk.kyc.uploadFileForVerification(backPath, 'idBack');
      }

      // Submit to verification endpoint
      debugPrint('[KYC] Submitting document for verification...');
      final result = await sdk.kyc.submitDocumentVerification(
        docType: docType,
        frontImageKey: frontKey,
        backImageKey: backKey,
      );

      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void resetFlow() {
    state = state.resetDocuments();
  }

  void clearError() {
    state = state.clearError();
  }

  void setTargetTier(KycTier tier) {
    state = state.copyWith(targetTier: tier);
  }

  Future<void> submitAddressVerification({
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String documentType,
    required String documentPath,
  }) async {
    this.state = this.state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);

      await sdk.kyc.submitAddressVerification(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        documentType: documentType,
        documentPath: documentPath,
      );

      this.state = this.state.copyWith(
        isLoading: false,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
      );
    } catch (e) {
      this.state = this.state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitVideoVerification(String videoPath) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);

      await sdk.kyc.submitVideoVerification(videoPath: videoPath);

      state = state.copyWith(
        isLoading: false,
        videoPath: videoPath,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitAdditionalDocuments({
    required String occupation,
    required String employer,
    required String monthlyIncome,
    required String sourceOfFunds,
    required String sourceDetails,
    required List<String> supportingDocuments,
  }) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final sdk = ref.read(sdkProvider);

      await sdk.kyc.submitAdditionalDocuments(
        occupation: occupation,
        employer: employer,
        monthlyIncome: monthlyIncome,
        sourceOfFunds: sourceOfFunds,
        sourceDetails: sourceDetails,
        supportingDocuments: supportingDocuments,
      );

      state = state.copyWith(
        isLoading: false,
        status: KycStatus.submitted,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

final kycProvider = NotifierProvider<KycNotifier, KycState>(
  KycNotifier.new,
);
