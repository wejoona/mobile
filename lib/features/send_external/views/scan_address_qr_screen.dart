import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/merchant_pay/widgets/qr_scanner_widget.dart';
import 'package:usdc_wallet/features/send_external/services/external_transfer_service.dart';

/// Screen for scanning QR codes containing wallet addresses
class ScanAddressQrScreen extends ConsumerWidget {
  const ScanAddressQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: QrScannerWidget(
        title: l10n.sendExternal_scanQr,
        subtitle: 'Position the wallet address QR code within the frame',
        onScan: (qrData) => _handleScan(context, ref, qrData),
        onError: () => _handleError(context),
      ),
    );
  }

  void _handleScan(BuildContext context, WidgetRef ref, String qrData) {
    final service = ref.read(externalTransferServiceProvider);
    final address = service.parseAddressFromQr(qrData);

    if (address != null) {
      // Valid address found - return it
      context.pop(address);
    } else {
      // Invalid QR code - show error
      _showError(context, 'Invalid QR code. Not a valid wallet address.');
      // Allow rescanning
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          // Scanner will automatically resume
        }
      });
    }
  }

  void _handleError(BuildContext context) {
    _showError(context, 'Camera error. Please try again.');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
