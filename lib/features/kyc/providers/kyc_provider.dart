import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kyc_status.dart';
import '../models/kyc_document.dart';
import '../models/document_type.dart';
import '../models/kyc_submission.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';

class KycState {
  final KycStatus status;
  final String? rejectionReason;
  final bool isLoading;
  final String? error;
  final DocumentType? selectedDocumentType;
  final List<KycDocument> capturedDocuments;
  final String? selfiePath;
  final double uploadProgress;

  const KycState({
    this.status = KycStatus.pending,
    this.rejectionReason,
    this.isLoading = false,
    this.error,
    this.selectedDocumentType,
    this.capturedDocuments = const [],
    this.selfiePath,
    this.uploadProgress = 0.0,
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

  KycState copyWith({
    KycStatus? status,
    String? rejectionReason,
    bool? isLoading,
    String? error,
    DocumentType? selectedDocumentType,
    List<KycDocument>? capturedDocuments,
    String? selfiePath,
    double? uploadProgress,
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
      );

      state = state.copyWith(
        isLoading: false,
        status: KycStatus.submitted,
        uploadProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        uploadProgress: 0.0,
      );
    }
  }

  void resetFlow() {
    state = state.resetDocuments();
  }

  void clearError() {
    state = state.clearError();
  }
}

final kycProvider = NotifierProvider<KycNotifier, KycState>(
  KycNotifier.new,
);
