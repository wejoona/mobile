import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'kyc_provider.dart';

/// KYC submission flow state.
class KycSubmissionState {
  final KycStep currentStep;
  final bool isLoading;
  final String? error;
  final Map<String, String> personalInfo;
  final File? idFront;
  final File? idBack;
  final File? selfie;
  final bool isComplete;

  const KycSubmissionState({
    this.currentStep = KycStep.personalInfo,
    this.isLoading = false,
    this.error,
    this.personalInfo = const {},
    this.idFront,
    this.idBack,
    this.selfie,
    this.isComplete = false,
  });

  KycSubmissionState copyWith({
    KycStep? currentStep, bool? isLoading, String? error,
    Map<String, String>? personalInfo, File? idFront, File? idBack,
    File? selfie, bool? isComplete,
  }) => KycSubmissionState(
    currentStep: currentStep ?? this.currentStep,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    personalInfo: personalInfo ?? this.personalInfo,
    idFront: idFront ?? this.idFront,
    idBack: idBack ?? this.idBack,
    selfie: selfie ?? this.selfie,
    isComplete: isComplete ?? this.isComplete,
  );
}

/// KYC steps.
enum KycStep {
  personalInfo('Informations personnelles'),
  documentType('Type de document'),
  documentCapture('Capture du document'),
  selfie('Selfie'),
  review('Verification'),
  submitted('Soumis');

  final String label;
  const KycStep(this.label);
}

/// KYC submission notifier.
class KycSubmissionNotifier extends Notifier<KycSubmissionState> {
  @override
  KycSubmissionState build() => const KycSubmissionState();

  void setPersonalInfo(Map<String, String> info) => state = state.copyWith(personalInfo: info);
  void setIdFront(File file) => state = state.copyWith(idFront: file);
  void setIdBack(File file) => state = state.copyWith(idBack: file);
  void setSelfie(File file) => state = state.copyWith(selfie: file);
  void goToStep(KycStep step) => state = state.copyWith(currentStep: step);

  void nextStep() {
    final steps = KycStep.values;
    final idx = steps.indexOf(state.currentStep);
    if (idx < steps.length - 1) {
      state = state.copyWith(currentStep: steps[idx + 1]);
    }
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(kycServiceProvider);
      // Submit personal info
      await service.submitKyc(data: state.personalInfo);

      // Upload documents
      if (state.idFront != null) {
        await service.uploadDocument(type: 'id_front', filePath: state.idFront!.path);
      }
      if (state.idBack != null) {
        await service.uploadDocument(type: 'id_back', filePath: state.idBack!.path);
      }
      if (state.selfie != null) {
        await service.uploadDocument(type: 'selfie', filePath: state.selfie!.path);
      }

      state = state.copyWith(isLoading: false, isComplete: true, currentStep: KycStep.submitted);
      ref.invalidate(kycProfileProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const KycSubmissionState();
}

final kycSubmissionProvider = NotifierProvider<KycSubmissionNotifier, KycSubmissionState>(KycSubmissionNotifier.new);
