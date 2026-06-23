import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/index.dart';

class CreateWalletView extends ConsumerStatefulWidget {
  const CreateWalletView({super.key});

  @override
  ConsumerState<CreateWalletView> createState() => _CreateWalletViewState();
}

class _CreateWalletViewState extends ConsumerState<CreateWalletView> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_ensureWallet());
    });
  }

  Future<void> _ensureWallet() async {
    if (_started) {
      return;
    }
    _started = true;

    final notifier = ref.read(walletStateMachineProvider.notifier);
    final wallet = ref.read(walletStateMachineProvider);
    if (wallet.hasWallet) {
      if (mounted) {
        context.fsmGo('/home');
      }
      return;
    }

    await notifier.createWallet();
    if (!mounted) {
      return;
    }

    final next = ref.read(walletStateMachineProvider);
    if (next.hasWallet) {
      context.fsmGo('/home');
    }
  }

  Future<void> _retry() async {
    _started = false;
    await _ensureWallet();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletStateMachineProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isLoading =
        wallet.status == WalletStatus.loading ||
        wallet.status == WalletStatus.initial;

    ref.listen(walletStateMachineProvider, (previous, next) {
      if (next.hasWallet && mounted) {
        context.fsmGo('/home');
      }
    });

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.goldSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colors.gold,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.wallet_createWallet,
                    variant: AppTextVariant.headlineSmall,
                    color: colors.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    wallet.error ?? l10n.wallet_createWalletMessage,
                    color: wallet.hasError
                        ? colors.errorText
                        : colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (isLoading)
                    CircularProgressIndicator(color: colors.gold)
                  else
                    AppButton(
                      label: wallet.hasError
                          ? l10n.action_retry
                          : l10n.wallet_createWallet,
                      onPressed: () => unawaited(_retry()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
