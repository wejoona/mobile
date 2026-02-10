import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// Provider Selection Screen
///
/// Shows available mobile money providers (Orange, MTN, Moov, Wave).
class ProviderSelectionScreen extends ConsumerWidget {
  const ProviderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose payment method',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to deposit funds',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Provider list
              Expanded(
                child: ListView(
                  children: MobileMoneyProvider.values.map((provider) {
                    return _ProviderTile(
                      provider: provider,
                      onTap: () {
                        ref.read(depositProvider.notifier).selectProvider(provider);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final MobileMoneyProvider provider;
  final VoidCallback onTap;

  const _ProviderTile({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _providerColor(provider).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _providerIcon(provider),
            color: _providerColor(provider),
          ),
        ),
        title: Text(
          provider.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _providerSubtitle(provider),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _providerColor(MobileMoneyProvider p) {
    switch (p) {
      case MobileMoneyProvider.orangeMoney:
        return Colors.orange;
      case MobileMoneyProvider.mtnMomo:
        return Colors.yellow.shade800;
      case MobileMoneyProvider.moovMoney:
        return Colors.blue;
      case MobileMoneyProvider.wave:
        return Colors.indigo;
    }
  }

  IconData _providerIcon(MobileMoneyProvider p) {
    switch (p) {
      case MobileMoneyProvider.orangeMoney:
        return Icons.phone_android;
      case MobileMoneyProvider.mtnMomo:
        return Icons.phone_android;
      case MobileMoneyProvider.moovMoney:
        return Icons.phone_android;
      case MobileMoneyProvider.wave:
        return Icons.qr_code;
    }
  }

  String _providerSubtitle(MobileMoneyProvider p) {
    switch (p.defaultPaymentMethodType) {
      case PaymentMethodType.otp:
        return 'Enter OTP code';
      case PaymentMethodType.push:
        return 'Approve on your phone';
      case PaymentMethodType.qrLink:
        return 'Scan QR or open app';
      case PaymentMethodType.card:
        return 'Card payment';
    }
  }
}
