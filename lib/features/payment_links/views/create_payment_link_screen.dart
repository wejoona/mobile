import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/payment_links/providers/create_payment_link_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Create payment link screen.
class CreatePaymentLinkScreen extends ConsumerStatefulWidget {
  const CreatePaymentLinkScreen({super.key});

  @override
  ConsumerState<CreatePaymentLinkScreen> createState() => _CreatePaymentLinkScreenState();
}

class _CreatePaymentLinkScreenState extends ConsumerState<CreatePaymentLinkScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPaymentLinkProvider);
    final notifier = ref.read(createPaymentLinkProvider.notifier);

    if (state.result != null) {
      return _LinkCreatedScreen(link: state.result!, onDone: () {
        notifier.reset();
        Navigator.pop(context, true);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.paymentLinks_create)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: AppStrings.amount,
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'USDC',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) {
                final amount = double.tryParse(v);
                if (amount != null) notifier.setAmount(amount);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLength: 200,
              onChanged: notifier.setDescription,
            ),
            const SizedBox(height: AppSpacing.md),

            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.paymentLinks_singleUse),
              subtitle: Text(AppLocalizations.of(context)!.paymentLinks_singleUseDescription),
              value: state.oneTime ?? true,
              onChanged: notifier.setOneTime,
            ),

            const Spacer(),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),

            FilledButton(
              onPressed: state.amount != null && !state.isLoading ? () => notifier.create() : null,
              child: state.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppLocalizations.of(context)!.paymentLinks_generate),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCreatedScreen extends StatelessWidget {
  final CreatedPaymentLink link;
  final VoidCallback onDone;

  const _LinkCreatedScreen({required this.link, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.paymentLinks_created)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(AppLocalizations.of(context)!.paymentLinks_ready, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(child: Text(link.url, style: Theme.of(context).textTheme.bodySmall)),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: link.url));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.paymentLinks_copied)));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: Text(AppLocalizations.of(context)!.action_share),
                    onPressed: () {
                      // SharePlus.instance.share(ShareParams(text: link.url))
                    },
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton(onPressed: onDone, child: Text(AppStrings.done)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
