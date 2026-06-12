import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BrandedQrImage extends StatelessWidget {
  const BrandedQrImage({
    required this.data,
    super.key,
    this.size = 220,
    this.backgroundColor = Colors.white,
    this.eyeStyle = const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF1A1A2E),
    ),
    this.dataModuleStyle = const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF1A1A2E),
    ),
  });

  final String data;
  final double size;
  final Color backgroundColor;
  final QrEyeStyle eyeStyle;
  final QrDataModuleStyle dataModuleStyle;

  @override
  Widget build(BuildContext context) => QrImageView(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    size: size,
    backgroundColor: backgroundColor,
    embeddedImage: const AssetImage('assets/images/app_icon.png'),
    embeddedImageStyle: QrEmbeddedImageStyle(
      size: Size(size * 0.18, size * 0.18),
    ),
    eyeStyle: eyeStyle,
    dataModuleStyle: dataModuleStyle,
  );
}
