import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Widget to display user's QR code for receiving payments.
class QrCodeDisplay extends StatelessWidget {
  final String data;
  final String? displayName;
  final String? title;
  final String? subtitle;
  final String? footer;
  final double size;
  final VoidCallback? onShare;

  const QrCodeDisplay({
    super.key,
    required this.data,
    this.displayName,
    this.title,
    this.subtitle,
    this.footer,
    this.size = 240,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (displayName != null) ...[
          Text(displayName!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF1A1A2E)),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF1A1A2E)),
          ),
        ),
        const SizedBox(height: 16),
        Text('Scan to pay me', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (onShare != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share QR Code'),
          ),
        ],
      ],
    );
  }
}
