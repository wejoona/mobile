import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/merchant_provider.dart';
import '../services/merchant_service.dart';
import '../widgets/qr_scanner_widget.dart';
import 'payment_confirm_view.dart';

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
    final state = ref.watch(scanToPayProvider);

    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner
          if (state.isScanning)
            QrScannerWidget(
              onScan: _onQrScanned,
              title: 'Scan to Pay',
              subtitle: 'Point your camera at the merchant\'s QR code',
            ),

          // Loading overlay
          if (state.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error snackbar
          if (state.error != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(scanToPayProvider.notifier).goBackToScanning();
                        _scannedQrData = null;
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
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
