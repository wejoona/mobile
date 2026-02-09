import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';
import '../../qr_payment/widgets/qr_display.dart';
import '../../auth/providers/auth_provider.dart';

class ReceiveView extends ConsumerStatefulWidget {
  const ReceiveView({super.key});

  @override
  ConsumerState<ReceiveView> createState() => _ReceiveViewState();
}

class _ReceiveViewState extends ConsumerState<ReceiveView> {
  Timer? _refreshTimer;
  String _nonce = _generateNonce();
  int _timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static String _generateNonce() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        setState(() {
          _nonce = _generateNonce();
          _timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _buildQrData(String userId, String? phone) {
    final data = {
      'type': 'payment',
      'userId': userId,
      if (phone != null) 'phone': phone,
      'timestamp': _timestamp,
      'nonce': _nonce,
    };
    return 'joonapay://pay?data=${base64Url.encode(utf8.encode(jsonEncode(data)))}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final walletState = ref.watch(walletStateMachineProvider);
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id ?? walletState.walletId;
    final phone = authState.phone ?? authState.user?.phone;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.receive_title,
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

            // Dynamic QR Code
            if (walletState.hasWalletAddress || userId.isNotEmpty)
              QrDisplay(
                data: _buildQrData(userId, phone),
                size: 220,
                title: l10n.receive_receiveUsdc,
                subtitle: l10n.receive_onlySendUsdc,
              )
            else if (walletState.isLoading)
              Container(
                width: 268,
                height: 268,
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                ),
                child: Center(
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.textTertiary,
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
                      onPressed: () => _copyAddress(context, l10n, walletState.walletAddress!),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.action_share,
                      icon: Icons.share,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _shareAddress(l10n, walletState.walletAddress!),
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
                        AppText(
                          l10n.receive_important,
                          variant: AppTextVariant.labelMedium,
                          color: AppColors.warningBase,
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

  void _copyAddress(BuildContext context, AppLocalizations l10n, String address) {
    Clipboard.setData(ClipboardData(text: address));

    // SECURITY: Auto-clear clipboard after 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.receive_addressCopied),
        backgroundColor: AppColors.successBase,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareAddress(AppLocalizations l10n, String address) {
    Share.share(
      l10n.receive_shareMessage(address),
      subject: l10n.receive_shareSubject,
    );
  }
}
