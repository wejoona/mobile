import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';

class ReceiveView extends ConsumerWidget {
  const ReceiveView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final walletState = ref.watch(walletStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          'Receive USDC',
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // QR Code
            if (walletState.hasWalletAddress)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: walletState.walletAddress!,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1A1A1F), // Always dark for visibility
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A1F), // Always dark for visibility
                  ),
                ),
              )
            else if (walletState.isLoading)
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: colors.gold),
                ),
              )
            else
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colors.textTertiary,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        'Wallet address not available',
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            // Wallet Address
            if (walletState.hasWalletAddress) ...[
              AppText(
                'Your Wallet Address',
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.elevated,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    SelectableText(
                      walletState.walletAddress!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Action buttons
            if (walletState.hasWalletAddress) ...[
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Copy',
                      icon: Icons.copy,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _copyAddress(context, walletState.walletAddress!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Share',
                      icon: Icons.share,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _shareAddress(walletState.walletAddress!),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.xxxl),

            // Warning
            AppCard(
              variant: AppCardVariant.subtle,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warningBase,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'Important',
                          variant: AppTextVariant.labelMedium,
                          color: AppColors.warningBase,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          'Only send USDC to this address. Sending other tokens may result in permanent loss of funds.',
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));

    // SECURITY: Auto-clear clipboard after 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard (auto-clears in 60s)'),
        backgroundColor: AppColors.successBase,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _shareAddress(String address) {
    Share.share(
      'Send USDC to my JoonaPay wallet:\n\n$address',
      subject: 'My JoonaPay Wallet Address',
    );
  }
}
