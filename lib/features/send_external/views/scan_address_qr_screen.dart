import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../services/external_transfer_service.dart';

/// Screen for scanning QR codes containing wallet addresses
class ScanAddressQrScreen extends ConsumerStatefulWidget {
  const ScanAddressQrScreen({super.key});

  @override
  ConsumerState<ScanAddressQrScreen> createState() => _ScanAddressQrScreenState();
}

class _ScanAddressQrScreenState extends ConsumerState<ScanAddressQrScreen> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _isScannerInitialized = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      _initScanner();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
    }
  }

  Future<void> _initScanner() async {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: false,
    );

    try {
      await _scannerController!.start();
      if (mounted) {
        setState(() => _isScannerInitialized = true);
      }
    } catch (e) {
      debugPrint('Scanner initialization error: $e');
      if (mounted) {
        setState(() => _permissionDenied = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.sendExternal_scanQr,
          variant: AppTextVariant.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _permissionDenied
          ? _buildPermissionDenied(l10n)
          : _buildScanner(l10n),
    );
  }

  Widget _buildScanner(AppLocalizations l10n) {
    if (!_isScannerInitialized || _scannerController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.gold500),
            SizedBox(height: AppSpacing.lg),
            AppText(
              'Initializing camera...',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Scanner
        MobileScanner(
          controller: _scannerController!,
          onDetect: _onDetect,
        ),

        // Dark overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // Scanner frame
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold500, width: 3),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
        ),

        // Instructions
        Positioned(
          bottom: AppSpacing.xxl * 2,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.slate.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.gold500,
                  size: 32,
                ),
                SizedBox(height: AppSpacing.sm),
                AppText(
                  'Scan wallet address QR code',
                  variant: AppTextVariant.bodyMedium,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  'Position the QR code within the frame',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              'Camera Permission Required',
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              'Please grant camera permission to scan QR codes',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Open Settings',
              onPressed: () => openAppSettings(),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    // Parse address from QR data
    final service = ref.read(externalTransferServiceProvider);
    final address = service.parseAddressFromQr(qrData);

    if (address != null) {
      // Valid address found - return it
      setState(() => _isScanning = false);
      context.pop(address);
    } else {
      // Invalid QR code - show error
      setState(() => _isScanning = false);
      _showError('Invalid QR code. Not a valid wallet address.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorBase,
        duration: const Duration(seconds: 2),
      ),
    );

    // Re-enable scanning after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isScanning = true);
      }
    });
  }
}
