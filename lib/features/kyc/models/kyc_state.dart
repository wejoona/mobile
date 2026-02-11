import 'package:usdc_wallet/domain/enums/index.dart';

/// KYC flow state used by views.
class KycState {
  final bool isLoading;
  final String? error;
  final KycStatus status;
  final Map<String, dynamic> personalInfo;
  final List<String> documentPaths;
  final String? selfiePath;
  final String? documentType;
  final int currentStep;
  final String? selectedDocumentType;
  final Map<String, String> capturedDocuments;
  final String? rejectionReason;
  final String? verificationStatus;
  final bool canStartVerification;

  const KycState({
    this.isLoading = false,
    this.error,
    this.status = KycStatus.none,
    this.personalInfo = const {},
    this.documentPaths = const [],
    this.selfiePath,
    this.documentType,
    this.currentStep = 0,
    this.selectedDocumentType,
    this.capturedDocuments = const {},
    this.rejectionReason,
    this.verificationStatus,
    this.canStartVerification = true,
  });

  KycState copyWith({
    bool? isLoading,
    String? error,
    KycStatus? status,
    Map<String, dynamic>? personalInfo,
    List<String>? documentPaths,
    String? selfiePath,
    String? documentType,
    int? currentStep,
    bool clearError = false,
    String? selectedDocumentType,
    Map<String, String>? capturedDocuments,
    String? rejectionReason,
    String? verificationStatus,
    bool? canStartVerification,
  }) => KycState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    status: status ?? this.status,
    personalInfo: personalInfo ?? this.personalInfo,
    documentPaths: documentPaths ?? this.documentPaths,
    selfiePath: selfiePath ?? this.selfiePath,
    documentType: documentType ?? this.documentType,
    currentStep: currentStep ?? this.currentStep,
    selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
    capturedDocuments: capturedDocuments ?? this.capturedDocuments,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    canStartVerification: canStartVerification ?? this.canStartVerification,
  );
}
