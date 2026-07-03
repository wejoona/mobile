import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/qr_payment/services/qr_code_service.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/qr_display.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/index.dart';

class ReceiveView extends ConsumerStatefulWidget {
  const ReceiveView({super.key});

  @override
  ConsumerState<ReceiveView> createState() => _ReceiveViewState();
}

class _ReceiveViewState extends ConsumerState<ReceiveView> {
  final _qrService = QrCodeService();

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.microtask(() => ref.read(limitsProvider.notifier).fetchLimits()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final walletState = ref.watch(walletStateMachineProvider);
    final authState = ref.watch(authProvider);
    final limitsState = ref.watch(limitsProvider);
    final user = authState.user;
    final receiveQrData = walletState.hasWalletAddress
        ? _qrService.generateReceiveQr(
            phone: user?.phone ?? authState.phone ?? '',
            userId: user?.id,
            currency: 'USDC',
            name: user?.displayName,
            walletAddress: walletState.walletAddress,
          )
        : null;
    final receivePermissions = limitsState.limits?.permissions;
    final canReceive = receivePermissions?.canReceive == true;
    final receiveBlockReason =
        receivePermissions?.blockReason?.trim().isNotEmpty == true
        ? receivePermissions!.blockReason!.trim()
        : receivePermissions?.reviewRequired == true
        ? l10n.moneyFlow_reviewRequiredMessage
        : l10n.moneyFlow_verificationRequiredMessage;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.receive_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.fsmPop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // Dynamic QR Code
            if (receivePermissions == null && limitsState.isLoading)
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: context.colors.gold),
                ),
              )
            else if (!canReceive)
              _buildReceiveBlockedState(context, receiveBlockReason)
            else if (walletState.hasWalletAddress)
              QrCodeDisplay(
                data: receiveQrData!,
                size: 220,
                title: l10n.receive_receiveUsdc,
                subtitle: l10n.receive_onlySendUsdc,
              )
            else if (walletState.isLoading)
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: context.colors.gold),
                ),
              )
            else
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colors.textTertiary,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.receive_walletNotAvailable,
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
                l10n.receive_yourWalletAddress,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.elevated,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SelectableText(
                  walletState.walletAddress!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
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
                      label: l10n.action_copy,
                      icon: Icons.copy,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _copyAddress(
                        context,
                        l10n,
                        walletState.walletAddress!,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.action_share,
                      icon: Icons.share,
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          _shareAddress(l10n, walletState.walletAddress!),
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
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.colors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.receive_important,
                          variant: AppTextVariant.labelMedium,
                          color: context.colors.warning,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          l10n.receive_warningMessage,
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

  Widget _buildReceiveBlockedState(BuildContext context, String message) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: context.colors.gold,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            message,
            variant: AppTextVariant.bodyMedium,
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyAddress(
    BuildContext context,
    AppLocalizations l10n,
    String address,
  ) {
    unawaited(Clipboard.setData(ClipboardData(text: address)));

    // SECURITY: Auto-clear clipboard after 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      unawaited(Clipboard.setData(const ClipboardData(text: '')));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.receive_addressCopied),
        backgroundColor: context.colors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareAddress(AppLocalizations l10n, String address) {
    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text: l10n.receive_shareMessage(address),
          title: l10n.receive_shareSubject,
        ),
      ),
    );
  }
}
