import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/send_provider.dart';
import '../providers/send_fee_provider.dart';
import '../providers/send_validation_provider.dart';
import '../providers/send_limits_provider.dart';
import '../../wallet/providers/balance_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/error/error_handler.dart';
import '../../../design/theme/spacing.dart';

/// Fully wired send money screen.
class SendScreenWired extends ConsumerStatefulWidget {
  const SendScreenWired({super.key});

  @override
  ConsumerState<SendScreenWired> createState() => _SendScreenWiredState();
}

class _SendScreenWiredState extends ConsumerState<SendScreenWired> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(sendMoneyProvider);
    final balance = ref.watch(availableBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sendMoney)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Available balance
            Text(
              'Solde disponible: \$${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Recipient
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppStrings.recipient,
                hintText: '+225 07 XX XX XX XX',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contacts_outlined),
                  onPressed: () {
                    // Open contacts picker
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (v) => ref.read(sendMoneyProvider.notifier).setRecipient(v),
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: AppStrings.amount,
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'USDC',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final amount = double.tryParse(v);
                if (amount != null) {
                  // Check limit
                  final limit = ref.read(sendLimitCheckProvider(amount));
                  if (!limit.isWithinLimits) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(limit.limitMessage ?? '')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Note (optional)
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '${AppStrings.note} (optionnel)',
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: AppSpacing.md),

            // Fee estimate
            if (_amountController.text.isNotEmpty)
              Consumer(builder: (context, ref, _) {
                final amount = double.tryParse(_amountController.text) ?? 0;
                final feeAsync = ref.watch(sendFeeProvider(amount));
                return feeAsync.when(
                  data: (fee) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${AppStrings.fee}:', style: Theme.of(context).textTheme.bodySmall),
                      Text('\$${fee.fee.toStringAsFixed(4)}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              }),

            const Spacer(),

            // Error
            if (sendState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(sendState.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            // Submit
            FilledButton(
              onPressed: sendState.isLoading ? null : () async {
                final success = await ref.read(sendMoneyProvider.notifier).executeTransfer();
                if (success && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/transfer-success');
                }
              },
              child: sendState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppStrings.send),
            ),
          ],
        ),
      ),
    );
  }
}
