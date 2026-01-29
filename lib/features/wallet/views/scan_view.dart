import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/wallet_provider.dart';

class ScanView extends ConsumerStatefulWidget {
  const ScanView({super.key});

  @override
  ConsumerState<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MobileScannerController? _scannerController;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isScanning = true;
  bool _isScannerInitialized = false;
  bool _isSharing = false;
  bool _isSaving = false;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initScanner();
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
    }
  }

  void _onTabChanged() {
    if (!_isScannerInitialized || _scannerController == null) return;

    if (_tabController.index == 0 && _scannedData == null) {
      _scannerController!.start();
      setState(() => _isScanning = true);
    } else {
      _scannerController!.stop();
      setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'QR Code',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.gold,
          labelColor: colors.gold,
          unselectedLabelColor: colors.textTertiary,
          tabs: const [
            Tab(text: 'Scan'),
            Tab(text: 'My QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scanner Tab
          _buildScannerTab(),
          // My QR Tab
          _buildMyQrTab(),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    if (_scannedData != null) {
      return _buildScannedResult();
    }

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

        // Overlay
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl - 2),
              child: MobileScanner(
                controller: _scannerController!,
                onDetect: _onDetect,
              ),
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
                // Top left
                Positioned(
                  top: 0,
                  left: 0,
                  child: _CornerDecoration(position: CornerPosition.topLeft),
                ),
                // Top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CornerDecoration(position: CornerPosition.topRight),
                ),
                // Bottom left
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _CornerDecoration(position: CornerPosition.bottomLeft),
                ),
                // Bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _CornerDecoration(position: CornerPosition.bottomRight),
                ),
              ],
            ),
          ),
        ),

        // Instructions
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
              // Torch toggle
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannedResult() {
    final colors = context.colors;
    final isValid = _isValidJoonaPayQr(_scannedData!);
    final parsedData = _parseQrData(_scannedData!);

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

          if (isValid && parsedData != null) ...[
            AppCard(
              variant: AppCardVariant.elevated,
              child: Column(
                children: [
                  _InfoRow(label: 'Type', value: parsedData['type'] ?? 'Payment', colors: colors),
                  if (parsedData['phone'] != null && parsedData['phone']!.isNotEmpty)
                    _InfoRow(label: 'Phone', value: parsedData['phone']!, colors: colors),
                  if (parsedData['address'] != null && parsedData['address']!.isNotEmpty)
                    _InfoRow(label: 'Address', value: _truncateAddress(parsedData['address']!), colors: colors),
                  if (parsedData['amount'] != null && parsedData['amount']!.isNotEmpty)
                    _InfoRow(label: 'Amount', value: '\$${parsedData['amount']}', colors: colors),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              label: 'Send Money',
              onPressed: () {
                final phone = parsedData['phone'];
                final address = parsedData['address'];
                if (phone != null && phone.isNotEmpty) {
                  context.push('/send', extra: {'phone': phone});
                } else if (address != null && address.isNotEmpty) {
                  context.push('/send', extra: {'address': address});
                }
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

  Widget _buildMyQrTab() {
    final authState = ref.watch(authProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);

    final phone = authState.phone ?? authState.user?.phone ?? '';
    final qrData = _generateQrData(phone);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // QR Code Card (wrapped in Screenshot for sharing)
          Screenshot(
            controller: _screenshotController,
            child: AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF1A1A2E),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // User info
                  AppText(
                    'JoonaPay',
                    variant: AppTextVariant.titleLarge,
                    color: context.colors.gold,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    phone,
                    variant: AppTextVariant.bodyLarge,
                    color: context.colors.textPrimary,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Wallet address (if available)
                  balanceAsync.when(
                    data: (balance) {
                      final colors = context.colors;
                      return Column(
                        children: [
                          Divider(color: colors.borderSubtle),
                          const SizedBox(height: AppSpacing.lg),
                          AppText(
                            'Wallet Address',
                            variant: AppTextVariant.labelMedium,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                _truncateAddress(balance.walletId),
                                variant: AppTextVariant.bodyMedium,
                                color: colors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: () => _copyToClipboard(balance.walletId),
                                child: Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: colors.gold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _isSharing ? '...' : 'Share',
                  onPressed: _isSharing ? null : () => _shareQr(phone),
                  variant: AppButtonVariant.secondary,
                  icon: Icons.share,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _isSaving ? '...' : 'Save',
                  onPressed: _isSaving ? null : _saveToGallery,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.save_alt,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Copy',
                  onPressed: () => _copyToClipboard(qrData),
                  variant: AppButtonVariant.secondary,
                  icon: Icons.copy,
                  size: AppButtonSize.small,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Instructions
          AppCard(
            variant: AppCardVariant.subtle,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: context.colors.gold, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        'Share this QR code to receive payments',
                        variant: AppTextVariant.bodyMedium,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  'Anyone with JoonaPay can scan this code to send you money instantly.',
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _scannedData != null) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _scannedData = barcode.rawValue;
      _isScanning = false;
    });

    _scannerController?.stop();
    HapticFeedback.mediumImpact();
  }

  bool _isValidJoonaPayQr(String data) {
    // Check if it's a JoonaPay QR format
    return data.startsWith('joonapay://') ||
        data.startsWith('+') || // Phone number
        data.startsWith('0x'); // Wallet address
  }

  Map<String, String?>? _parseQrData(String data) {
    if (data.startsWith('joonapay://')) {
      // Parse joonapay:// URL
      // Format: joonapay://pay?phone=+225xxx&amount=10
      final uri = Uri.parse(data);
      return {
        'type': uri.host == 'pay' ? 'Payment' : 'Unknown',
        'phone': uri.queryParameters['phone'],
        'address': uri.queryParameters['address'],
        'amount': uri.queryParameters['amount'],
      };
    } else if (data.startsWith('+')) {
      // Phone number
      return {'type': 'Phone', 'phone': data};
    } else if (data.startsWith('0x')) {
      // Wallet address
      return {'type': 'Wallet', 'address': data};
    }
    return null;
  }

  String _generateQrData(String phone) {
    return 'joonapay://pay?phone=$phone';
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppColors.successBase,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Capture the QR card as image
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'joonapay_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        final success = result['isSuccess'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'QR code saved to gallery' : 'Failed to save QR code',
            ),
            backgroundColor: success ? AppColors.successBase : AppColors.errorBase,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareQr(String phone) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      // Capture the QR card as image
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/joonapay_qr_$phone.png');
      await file.writeAsBytes(imageBytes);

      // Share the image with text
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan this QR code to send me money on JoonaPay!\n\nPhone: $phone',
        subject: 'JoonaPay Payment QR Code',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
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
      ..color = AppColors.gold500 // Static color for QR decoration
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
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}
