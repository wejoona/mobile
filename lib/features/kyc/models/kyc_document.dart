import 'document_type.dart';

enum DocumentSide { front, back }

class KycDocument {
  final DocumentType type;
  final String imagePath;
  final DocumentSide side;

  const KycDocument({
    required this.type,
    required this.imagePath,
    required this.side,
  });

  KycDocument copyWith({
    DocumentType? type,
    String? imagePath,
    DocumentSide? side,
  }) {
    return KycDocument(
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      side: side ?? this.side,
    );
  }
}
