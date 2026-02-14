import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/qr_display.dart';
import 'package:usdc_wallet/features/merchant_pay/widgets/qr_scanner_widget.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ScanView extends ConsumerStatefulWidget {
  const ScanView({super.key});

  @override
  ConsumerState<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.action_scan,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.gold,
          labelColor: context.colors.gold,
          unselectedLabelColor: context.colors.textTertiary,
          tabs: [
            Tab(text: l10n.action_scan),
            const Tab(text: 'My QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(l10n),
          _buildMyQrTab(l10n),
        ],
      ),
    );
  }

  Widget _buildScannerTab(AppLocalizations l10n) {
    return QrScannerWidget(
      onScan: (qrData) => _handleScannedData(qrData),
      title: 'Scan QR Code',
      subtitle: 'Point your camera at a wallet address or payment QR code',
    );
  }

  void _handleScannedData(String qrData) {
    // Parse and navigate
    if (qrData.startsWith('joonapay://pay')) {
      final uri = Uri.parse(qrData);
      final phone = uri.queryParameters['phone'];
      final address = uri.queryParameters['address'];

      if (phone != null && phone.isNotEmpty) {
        context.push('/send', extra: {'phone': phone});
      } else if (address != null && address.isNotEmpty) {
        context.push('/send', extra: {'address': address});
      }
    } else if (qrData.startsWith('+')) {
      // Phone number QR
      context.push('/send', extra: {'phone': qrData});
    } else if (qrData.startsWith('0x') && qrData.length >= 20) {
      // Wallet address QR
      context.push('/send', extra: {'address': qrData});
    } else {
      // Invalid QR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid QR code. Please scan a Korido payment code.'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  Widget _buildMyQrTab(AppLocalizations l10n) {
    final walletState = ref.watch(walletStateMachineProvider);
    final authState = ref.watch(authProvider);

    final phone = authState.phone ?? authState.user?.phone ?? '';
    final walletAddress = walletState.walletAddress ?? '';
    final qrData = 'joonapay://pay?phone=$phone${walletAddress.isNotEmpty ? '&address=$walletAddress' : ''}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // QR Code with screenshot wrapper
          Screenshot(
            controller: _screenshotController,
            child: QrCodeDisplay(
              data: qrData,
              size: 200,
              title: 'Korido',
              subtitle: phone,
              footer: walletAddress.isNotEmpty ? walletAddress : null,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _isSharing ? '...' : l10n.action_share,
                  onPressed: _isSharing ? null : () => _shareQr(phone),
                  variant: AppButtonVariant.secondary,
                  icon: Icons.share,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _isSaving ? '...' : l10n.action_save,
                  onPressed: _isSaving ? null : _saveToGallery,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.save_alt,
                  size: AppButtonSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.action_copy,
                  onPressed: () => _copyToClipboard(qrData, l10n),
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
                  'Anyone with Korido can scan this code to send you money instantly.',
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

  // ignore: unused_element
  Widget _buildWalletAddressFooter(String address) {
    final truncated = address.length > 16
        ? '${address.substring(0, 8)}...${address.substring(address.length - 6)}'
        : address;

    return Column(
      children: [
        Divider(color: context.colors.borderSubtle),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              'Wallet: ',
              variant: AppTextVariant.bodySmall,
              color: context.colors.textTertiary,
            ),
            AppText(
              truncated,
              variant: AppTextVariant.bodySmall,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(String text, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.action_copiedToClipboard),
        backgroundColor: context.colors.success,
        duration: const Duration(seconds: 2),
      ),
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
        // ignore: avoid_dynamic_calls
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

  Future<void> _shareQr(String phone) async {
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
      final file = File('${tempDir.path}/korido_qr_$phone.png');
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Scan this QR code to send me money on Korido!\n\nPhone: $phone',
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
