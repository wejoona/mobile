import 'package:flutter/material.dart';

/// Merchant QR code scanner overlay.
class MerchantScannerOverlay extends StatelessWidget {
  final double scanAreaSize;

  const MerchantScannerOverlay({super.key, this.scanAreaSize = 250});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Darkened background
        ColoredBox(color: Colors.black.withValues(alpha: 0.5), child: const SizedBox.expand()),
        // Scan area cutout
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner brackets
                ..._corners(theme.colorScheme.primary),
              ],
            ),
          ),
        ),
        // Instructions
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Text(
            'Align merchant QR code within the frame',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
        ),
      ],
    );
  }

  List<Widget> _corners(Color color) {
    const size = 24.0;
    const thickness = 3.0;
    final decoration = BoxDecoration(
      border: Border(
        top: BorderSide(color: color, width: thickness),
        left: BorderSide(color: color, width: thickness),
      ),
    );

    return [
      Positioned(top: 0, left: 0, child: Container(width: size, height: size, decoration: decoration)),
      Positioned(top: 0, right: 0, child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(top: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness))))),
      Positioned(bottom: 0, left: 0, child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: thickness), left: BorderSide(color: color, width: thickness))))),
      Positioned(bottom: 0, right: 0, child: Container(width: size, height: size, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color, width: thickness), right: BorderSide(color: color, width: thickness))))),
    ];
  }
}
