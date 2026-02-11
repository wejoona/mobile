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

  const KycState({
    this.isLoading = false,
    this.error,
    this.status = KycStatus.none,
    this.personalInfo = const {},
    this.documentPaths = const [],
    this.selfiePath,
    this.documentType,
    this.currentStep = 0,
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
  }) => KycState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    status: status ?? this.status,
    personalInfo: personalInfo ?? this.personalInfo,
    documentPaths: documentPaths ?? this.documentPaths,
    selfiePath: selfiePath ?? this.selfiePath,
    documentType: documentType ?? this.documentType,
    currentStep: currentStep ?? this.currentStep,
  );
}
