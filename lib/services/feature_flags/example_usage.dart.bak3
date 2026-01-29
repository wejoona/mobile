import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature_flags_provider.dart';
import 'feature_gate.dart';

/// Example: Home Screen with Feature-Gated Actions
///
/// This demonstrates various ways to use feature flags in a real app.
class HomeScreenExample extends ConsumerWidget {
  const HomeScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('JoonaPay Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Simple feature gate
          FeatureGate(
            flag: FeatureFlagKeys.billPayments,
            child: const _BillPaymentsCard(),
            fallback: const _ComingSoonCard(feature: 'Bill Payments'),
          ),

          const SizedBox(height: 16),

          // Example 2: Feature gate builder for complex logic
          FeatureGateBuilder(
            flag: FeatureFlagKeys.savingsPots,
            builder: (context, isEnabled) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.savings),
                  title: const Text('Savings Pots'),
                  subtitle: Text(isEnabled ? 'Start saving today' : 'Coming soon'),
                  trailing: isEnabled
                      ? const Icon(Icons.arrow_forward_ios)
                      : const Chip(label: Text('Beta')),
                  onTap: isEnabled ? () => _navigateToSavings(context) : null,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Example 3: Multiple feature requirements
          MultiFeatureGate(
            flags: [
              FeatureFlagKeys.externalTransfers,
              FeatureFlagKeys.biometricAuth,
            ],
            child: const _SecureExternalTransferButton(),
            fallback: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Icon(Icons.lock_outline, size: 48),
                    SizedBox(height: 8),
                    Text('Secure transfers require biometric authentication'),
                    Text('Feature coming soon!', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example 4: Show services section if any service is available
          AnyFeatureGate(
            flags: [
              FeatureFlagKeys.billPayments,
              FeatureFlagKeys.airtime,
            ],
            child: const _ServicesSection(),
          ),

          const SizedBox(height: 16),

          // Example 5: Using convenience provider
          const _TransferButton(),

          const SizedBox(height: 16),

          // Example 6: Programmatic check in provider
          const _SettingsButton(),
        ],
      ),
    );
  }

  void _navigateToSavings(BuildContext context) {
    // Navigate to savings screen
  }
}

class _BillPaymentsCard extends StatelessWidget {
  const _BillPaymentsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: const Text('Pay Bills'),
        subtitle: const Text('Electricity, water, internet'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to bill payments
        },
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String feature;

  const _ComingSoonCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Icon(Icons.lock_outline, color: Colors.grey[400]),
        title: Text(feature),
        subtitle: Text('Coming soon', style: TextStyle(color: Colors.grey[400])),
        trailing: Chip(
          label: Text('Soon', style: TextStyle(fontSize: 10)),
          backgroundColor: Colors.orange,
        ),
      ),
    );
  }
}

class _SecureExternalTransferButton extends StatelessWidget {
  const _SecureExternalTransferButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to external transfer
      },
      icon: const Icon(Icons.send),
      label: const Text('Send to External Wallet'),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FeatureGate(
                flag: FeatureFlagKeys.airtime,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(Icons.phone_android),
                        SizedBox(height: 8),
                        Text('Airtime'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FeatureGate(
                flag: FeatureFlagKeys.billPayments,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Icon(Icons.receipt),
                        SizedBox(height: 8),
                        Text('Bills'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TransferButton extends ConsumerWidget {
  const _TransferButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using convenience provider
    final canTransferExternally = ref.watch(externalTransfersEnabledProvider);

    return ElevatedButton(
      onPressed: canTransferExternally
          ? () {
              // Navigate to transfer
            }
          : null,
      child: Text(
        canTransferExternally ? 'Send Money' : 'Send Money (Coming Soon)',
      ),
    );
  }
}

class _SettingsButton extends ConsumerWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _showSettings(context, ref),
      child: const Text('Security Settings'),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    // Programmatic flag check in action handler
    final has2FA = ref.read(twoFactorAuthEnabledProvider);
    final hasBiometric = ref.read(biometricAuthEnabledProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SecurityOption(
              title: 'Two-Factor Auth',
              isAvailable: has2FA,
            ),
            _SecurityOption(
              title: 'Biometric Auth',
              isAvailable: hasBiometric,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  final String title;
  final bool isAvailable;

  const _SecurityOption({
    required this.title,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.lock_outline,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          if (!isAvailable) const Text('Coming Soon', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
