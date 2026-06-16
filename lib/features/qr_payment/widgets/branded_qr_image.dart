import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';

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
    this.showBrandMark = true,
  });

  final String data;
  final double size;
  final Color backgroundColor;
  final QrEyeStyle eyeStyle;
  final QrDataModuleStyle dataModuleStyle;
  final bool showBrandMark;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('data', data.isEmpty ? '<empty>' : '<redacted>'))
      ..add(DoubleProperty('size', size))
      ..add(ColorProperty('backgroundColor', backgroundColor))
      ..add(DiagnosticsProperty<QrEyeStyle>('eyeStyle', eyeStyle))
      ..add(
        DiagnosticsProperty<QrDataModuleStyle>(
          'dataModuleStyle',
          dataModuleStyle,
        ),
      )
      ..add(FlagProperty('showBrandMark', value: showBrandMark, ifTrue: 'on'));
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.22;
    final iconSize = size * 0.14;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: data,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            size: size,
            backgroundColor: backgroundColor,
            eyeStyle: eyeStyle,
            dataModuleStyle: dataModuleStyle,
          ),
          if (showBrandMark)
            Container(
              width: badgeSize,
              height: badgeSize,
              padding: EdgeInsets.all(size * 0.035),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(size * 0.045),
                border: Border.all(color: const Color(0xFFE8C35B), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: size * 0.04,
                    offset: Offset(0, size * 0.012),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.028),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      KoridoMark(size: iconSize),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
