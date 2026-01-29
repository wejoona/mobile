/// Receipt export format
enum ReceiptFormat {
  /// PNG image format
  image,

  /// PDF document format
  pdf,
}

extension ReceiptFormatExtension on ReceiptFormat {
  String get label {
    switch (this) {
      case ReceiptFormat.image:
        return 'Image';
      case ReceiptFormat.pdf:
        return 'PDF';
    }
  }

  String get fileExtension {
    switch (this) {
      case ReceiptFormat.image:
        return 'png';
      case ReceiptFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ReceiptFormat.image:
        return 'image/png';
      case ReceiptFormat.pdf:
        return 'application/pdf';
    }
  }
}
