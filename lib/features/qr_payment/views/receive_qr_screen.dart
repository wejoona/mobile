import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/qr_payment/services/qr_code_service.dart';

/// Screen for displaying user's QR code to receive payments
class ReceiveQrScreen extends ConsumerStatefulWidget {
  const ReceiveQrScreen({super.key});

  @override
  ConsumerState<ReceiveQrScreen> createState() => _ReceiveQrScreenState();
}

class _ReceiveQrScreenState extends ConsumerState<ReceiveQrScreen> {
  final _qrService = QrCodeService();
  final _screenshotController = ScreenshotController();
  final _amountController = TextEditingController();

  bool _includeAmount = false;
  bool _isSharing = false;
  bool _isSaving = false;
  double? _brightness;
  int _qrTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  Timer? _qrRefreshTimer;

  @override
  void initState() {
    super.initState();
    _increaseBrightness();
    _startQrRefresh();
  }

  void _startQrRefresh() {
    _qrRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _qrTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        });
      }
    });
  }

  @override
  void dispose() {
    _qrRefreshTimer?.cancel();
    _amountController.dispose();
    _restoreBrightness();
    super.dispose();
  }

  // Increase screen brightness for better QR scanning
  Future<void> _increaseBrightness() async {
    try {
      // Store current brightness
      _brightness = await Screen.brightness;
      // Set to max
      await Screen.setBrightness(1.0);
    } catch (e) {
      // Brightness control not available on this device
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      if (_brightness != null) {
        await Screen.setBrightness(_brightness!);
      }
    } catch (e) {
      // Brightness control not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final authState = ref.watch(authProvider);
    final phone = authState.phone ?? authState.user?.phone ?? '';
    final name = authState.user?.fullName;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Receive Payment',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Amount input (optional)
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _includeAmount,
                        onChanged: (value) {
                          setState(() => _includeAmount = value ?? false);
                        },
                        activeColor: colors.gold,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        'Request specific amount',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  if (_includeAmount) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      label: 'Amount (USD)',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefix: const Text('\$ '),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // QR Code Card
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
                        data: _generateQrData(phone, name),
                        version: QrVersions.auto,
                        size: 220,
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

                    // App branding
                    AppText(
                      'Korido',
                      variant: AppTextVariant.titleLarge,
                      color: colors.gold,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Phone number
                    AppText(
                      _qrService.formatPhone(phone),
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),

                    if (name != null && name.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        name,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      ),
                    ],

                    if (_includeAmount && _amountController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Divider(color: colors.borderSubtle),
                      const SizedBox(height: AppSpacing.lg),
                      AppText(
                        'Amount',
                        variant: AppTextVariant.labelSmall,
                        color: colors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        '\$${_amountController.text} USD',
                        variant: AppTextVariant.headlineSmall,
                        color: colors.gold,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _isSharing ? '...' : 'Share',
                    onPressed: _isSharing ? null : () => _shareQr(phone, name),
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
                      Icon(Icons.info_outline, color: colors.gold, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          'How to receive payment',
                          variant: AppTextVariant.labelMedium,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    'Share this QR code with the sender. They can scan it with their Korido app to send you money instantly.',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateQrData(String phone, String? name) {
    double? amount;
    if (_includeAmount && _amountController.text.isNotEmpty) {
      amount = double.tryParse(_amountController.text);
    }

    return _qrService.generateReceiveQr(
      phone: phone,
      amount: amount,
      currency: 'USD',
      name: name,
      reference: 't=$_qrTimestamp',
    );
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'korido_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        final success = result['isSuccess'] == true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'QR code saved to gallery' : 'Failed to save QR code',
            ),
            backgroundColor: success ? context.colors.success : context.colors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareQr(String phone, String? name) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/korido_qr.png');
      await file.writeAsBytes(imageBytes);

      String shareText = 'Scan this QR code to send me money on Korido!\n\n';
      shareText += 'Phone: ${_qrService.formatPhone(phone)}';

      if (name != null && name.isNotEmpty) {
        shareText += '\nName: $name';
      }

      if (_includeAmount && _amountController.text.isNotEmpty) {
        shareText += '\nAmount: \$${_amountController.text} USD';
      }

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: shareText,
        title: 'Korido Payment QR Code',
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: context.colors.error,
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

// Helper class for screen brightness control
class Screen {
  static Future<double> get brightness async {
    // This is a simplified version - in real implementation,
    // you would use screen_brightness package or platform channels
    return 0.5;
  }

  static Future<void> setBrightness(double brightness) async {
    // This is a simplified version - in real implementation,
    // you would use screen_brightness package or platform channels
  }
}
