import 'package:usdc_wallet/features/kyc/models/kyc_document.dart';

class KycSubmission {
  final List<KycDocument> documents;
  final String? selfiePath;

  const KycSubmission({
    required this.documents,
    this.selfiePath,
  });

  bool get isComplete => documents.isNotEmpty && selfiePath != null;

  KycSubmission copyWith({
    List<KycDocument>? documents,
    String? selfiePath,
  }) {
    return KycSubmission(
      documents: documents ?? this.documents,
      selfiePath: selfiePath ?? this.selfiePath,
    );
  }
}
