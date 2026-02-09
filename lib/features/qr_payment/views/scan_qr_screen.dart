import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/logger.dart';
import '../services/qr_code_service.dart';
import '../models/qr_payment_data.dart';

/// Screen for scanning QR codes to send payments
class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final _qrService = QrCodeService();
  MobileScannerController? _scannerController;

  bool _isScanning = true;
  bool _isScannerInitialized = false;
  bool _permissionDenied = false;
  QrPaymentData? _scannedData;

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
      AppLogger('Scanner initialization error').error('Scanner initialization error', e);
      if (mounted) {
        setState(() => _permissionDenied = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Scan QR Code',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _scannedData != null
          ? _buildScannedResult()
          : _permissionDenied
              ? _buildPermissionDenied()
              : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    if (!_isScannerInitialized || _scannerController == null) {
      final colors = context.colors;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.gold),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Initializing camera...',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
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
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),

        // Scanner frame
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.gold, width: 3),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
        ),

        // Corner decorations
        Center(
          child: SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerDecoration(position: CornerPosition.topLeft),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerDecoration(position: CornerPosition.topRight),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerDecoration(position: CornerPosition.bottomLeft),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerDecoration(position: CornerPosition.bottomRight),
                ),
              ],
            ),
          ),
        ),

        // Instructions and controls
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              AppText(
                'Scan a JoonaPay QR code',
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                'Point your camera at a QR code to send money',
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Flash toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _scannerController?.toggleTorch(),
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.container,
                        shape: BoxShape.circle,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _scannerController!,
                        builder: (context, state, child) {
                          final colors = context.colors;
                          return Icon(
                            state.torchState == TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: state.torchState == TorchState.on
                                ? colors.gold
                                : colors.textSecondary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Gallery import (future feature)
                  IconButton(
                    onPressed: () {
                      // TODO: Implement gallery import
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gallery import coming soon'),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.container,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_library,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannedResult() {
    final colors = context.colors;
    final isValid = _scannedData != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success/Error icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isValid
                  ? AppColors.successBase.withValues(alpha: 0.1)
                  : AppColors.errorBase.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid ? Icons.check_circle : Icons.error,
              size: 60,
              color: isValid ? AppColors.successBase : AppColors.errorBase,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          AppText(
            isValid ? 'QR Code Scanned' : 'Invalid QR Code',
            variant: AppTextVariant.headlineSmall,
            color: colors.textPrimary,
          ),

          const SizedBox(height: AppSpacing.md),

          if (isValid && _scannedData != null) ...[
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Phone',
                    value: _qrService.formatPhone(_scannedData!.phone),
                    colors: colors,
                  ),
                  if (_scannedData!.name != null && _scannedData!.name!.isNotEmpty)
                    _InfoRow(
                      label: 'Name',
                      value: _scannedData!.name!,
                      colors: colors,
                    ),
                  if (_scannedData!.amount != null)
                    _InfoRow(
                      label: 'Amount',
                      value: '\$${_scannedData!.amount} ${_scannedData!.currency ?? "USD"}',
                      colors: colors,
                    ),
                  if (_scannedData!.reference != null && _scannedData!.reference!.isNotEmpty)
                    _InfoRow(
                      label: 'Reference',
                      value: _scannedData!.reference!,
                      colors: colors,
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Send Money',
              onPressed: () {
                // Navigate to send view with prefilled data
                context.pop(); // Close scanner
                context.push('/send', extra: {
                  'phone': _scannedData!.phone,
                  'amount': _scannedData!.amount?.toString(),
                  'reference': _scannedData!.reference,
                });
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ] else ...[
            AppText(
              'This QR code is not a valid JoonaPay payment code.',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: 'Scan Again',
            onPressed: () {
              setState(() {
                _scannedData = null;
                _isScanning = true;
              });
              _scannerController?.start();
            },
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied() {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'Camera Permission Required',
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'Please grant camera permission to scan QR codes.',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Open Settings',
              onPressed: () => openAppSettings(),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _scannedData != null) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    final parsedData = _qrService.parseQrData(barcode.rawValue!);

    setState(() {
      _scannedData = parsedData;
      _isScanning = false;
    });

    _scannerController?.stop();
    HapticFeedback.mediumImpact();
  }
}

enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({required this.position});

  final CornerPosition position;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(position: position),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.position});

  final CornerPosition position;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold500
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case CornerPosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          Flexible(
            child: AppText(
              value,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
