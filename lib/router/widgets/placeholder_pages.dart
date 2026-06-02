import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

/// Placeholder page for routes not yet implemented.
class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({required String title, super.key})
    : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    ),
    body: Center(
      child: Text(
        '$_title\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    ),
  );
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
