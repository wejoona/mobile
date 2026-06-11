import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Neutral fallback for routes that cannot be resolved from their arguments.
class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({required String title, super.key})
    : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) {
    final colors = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          _title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    color: colors.textTertiary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppText(
                  _title,
                  variant: AppTextVariant.titleLarge,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  'This page could not be opened. The item may have moved, expired, or is not available for your account.',
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: context.canPop() ? 'Go back' : 'Go home',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder for FSM state screens.
class FsmStatePlaceholder extends ConsumerWidget {
  const FsmStatePlaceholder({
    required String title,
    required String message,
    String? actionLabel,
    bool showAction = true,
    super.key,
  }) : _title = title,
       _message = message,
       _actionLabel = actionLabel,
       _showAction = showAction;

  final String _title;
  final String _message;
  final String? _actionLabel;
  final bool _showAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLabel = _actionLabel;

    return Scaffold(
      appBar: AppBar(title: Text(_title), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_showAction && actionLabel != null)
              AppButton(
                label: actionLabel,
                onPressed: () {
                  // Navigate based on the action.
                  if (actionLabel == 'Get New OTP') {
                    context.go('/login');
                  } else if (actionLabel == 'Contact Support') {
                    unawaited(context.push('/settings/help'));
                  } else if (actionLabel == 'Unlock') {
                    context.go('/login/pin');
                  } else if (actionLabel == 'Verify') {
                    // Trigger biometric verification.
                    context.pop();
                  } else if (actionLabel == 'Verify Device') {
                    context.go('/login/otp');
                  } else if (actionLabel == 'End Other Session') {
                    context.go('/settings/sessions');
                  } else if (actionLabel == 'View Status') {
                    context.go('/settings');
                  } else if (actionLabel == 'Renew KYC') {
                    unawaited(context.push('/kyc'));
                  } else if (actionLabel == 'Create Wallet') {
                    // Trigger wallet creation.
                    unawaited(
                      ref
                          .read(walletStateMachineProvider.notifier)
                          .createWallet()
                          .then((_) {
                            if (context.mounted) {
                              context.go('/home');
                            }
                          }),
                    );
                  }
                },
              ),
            if (!_showAction) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
