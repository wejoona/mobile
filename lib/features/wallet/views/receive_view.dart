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
    final walletState = ref.watch(walletStateMachineProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Receive USDC',
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
            const SizedBox(height: AppSpacing.lg),

            // Info card
            AppCard(
              variant: AppCardVariant.subtle,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.gold500,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          'Receive USDC',
                          variant: AppTextVariant.bodyLarge,
                          color: AppColors.textPrimary,
                        ),
                        AppText(
                          'Only send USDC on ${_getNetworkName(walletState.blockchain)} network',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // QR Code
            if (walletState.hasWalletAddress)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold500.withValues(alpha: 0.2),
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
                    color: AppColors.obsidian,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.obsidian,
                  ),
                ),
              )
            else if (walletState.isLoading)
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.gold500),
                ),
              )
            else
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.textTertiary,
                        size: 48,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        'Wallet address not available',
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            // Network badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.successBase,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppText(
                    _getNetworkName(walletState.blockchain),
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Wallet Address
            if (walletState.hasWalletAddress) ...[
              const AppText(
                'Your Wallet Address',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textSecondary,
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
                        color: AppColors.textPrimary,
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
                    child: _ActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onTap: () => _copyAddress(context, walletState.walletAddress!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () => _shareAddress(walletState.walletAddress!, walletState.blockchain),
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
                          'Only send USDC on the ${_getNetworkName(walletState.blockchain)} network to this address. Sending other tokens or using a different network may result in permanent loss of funds.',
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
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

  String _getNetworkName(String blockchain) {
    switch (blockchain.toUpperCase()) {
      case 'MATIC':
      case 'MATIC-AMOY':
        return 'Polygon';
      case 'ETH':
      case 'ETH-SEPOLIA':
        return 'Ethereum';
      case 'SOL':
      case 'SOL-DEVNET':
        return 'Solana';
      case 'AVAX':
        return 'Avalanche';
      case 'ARB':
        return 'Arbitrum';
      default:
        return blockchain;
    }
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

  void _shareAddress(String address, String blockchain) {
    final networkName = _getNetworkName(blockchain);
    Share.share(
      'Send USDC to my wallet on $networkName:\n\n$address',
      subject: 'My USDC Wallet Address',
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.gold500, size: 20),
            const SizedBox(width: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelMedium,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
