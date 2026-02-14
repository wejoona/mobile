import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/merchant_pay/providers/merchant_provider.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';
import 'package:usdc_wallet/features/merchant_pay/widgets/qr_scanner_widget.dart';
import 'package:usdc_wallet/features/merchant_pay/views/payment_confirm_view.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Scan QR View
/// Customer interface for scanning merchant QR codes
class ScanQrView extends ConsumerStatefulWidget {
  const ScanQrView({super.key});

  static const String routeName = '/scan-to-pay';

  @override
  ConsumerState<ScanQrView> createState() => _ScanQrViewState();
}

class _ScanQrViewState extends ConsumerState<ScanQrView> {
  String? _scannedQrData;

  @override
  void initState() {
    super.initState();
    // Reset the scan state when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanToPayProvider.notifier).resetScan();
    });
  }

  void _onQrScanned(String qrData) async {
    if (_scannedQrData == qrData) return; // Prevent duplicate scans
    _scannedQrData = qrData;

    final notifier = ref.read(scanToPayProvider.notifier);
    final success = await notifier.decodeQr(qrData);

    if (success && mounted) {
      // Navigate to confirmation view
      final state = ref.read(scanToPayProvider);
      if (state.scannedMerchant != null) {
        _showPaymentConfirmation(qrData, state.scannedMerchant!);
      }
    } else {
      // Reset to allow rescanning on error
      _scannedQrData = null;
    }
  }

  void _showPaymentConfirmation(String qrData, QrDecodeResponse merchant) {
    final __l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => PaymentConfirmView(
        qrData: qrData,
        merchant: merchant,
        onCancel: () {
          Navigator.of(context).pop();
          ref.read(scanToPayProvider.notifier).goBackToScanning();
          _scannedQrData = null;
        },
        onSuccess: () {
          Navigator.of(context).pop();
          _showSuccessAndNavigate();
        },
      ),
    );
  }

  void _showSuccessAndNavigate() {
    final payment = ref.read(scanToPayProvider).payment;
    if (payment != null) {
      context.push('/payment-receipt', extra: payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(scanToPayProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: Stack(
        children: [
          // QR Scanner
          if (state.isScanning)
            QrScannerWidget(
              onScan: _onQrScanned,
              title: l10n.action_scan,
              subtitle: 'Point your camera at the merchant\'s QR code',
            ),

          // Loading overlay
          if (state.isLoading)
            Container(
              color: context.colors.canvas.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: context.colors.gold),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      'Processing...',
                      variant: AppTextVariant.bodyLarge,
                      color: context.colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

          // Error snackbar
          if (state.error != null)
            Positioned(
              bottom: 100,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.error,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: context.colors.textPrimary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        state.error!,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(scanToPayProvider.notifier).goBackToScanning();
                        _scannedQrData = null;
                      },
                      icon: Icon(Icons.close, color: context.colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
