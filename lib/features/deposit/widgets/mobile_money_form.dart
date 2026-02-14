import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Run 365: Mobile money deposit form widget
class MobileMoneyForm extends ConsumerStatefulWidget {
  final ValueChanged<MobileMoneyDepositData> onSubmit;

  const MobileMoneyForm({super.key, required this.onSubmit});

  @override
  ConsumerState<MobileMoneyForm> createState() => _MobileMoneyFormState();
}

class _MobileMoneyFormState extends ConsumerState<MobileMoneyForm> {
  final _formKey = GlobalKey<FormState>();
  String _selectedProvider = 'orange_money';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  final _providers = const [
    _MoMoProvider(id: 'orange_money', name: 'Orange Money', prefix: '+225 07'),
    _MoMoProvider(id: 'mtn_momo', name: 'MTN MoMo', prefix: '+225 05'),
    _MoMoProvider(id: 'wave', name: 'Wave', prefix: '+225 01'),
    _MoMoProvider(id: 'moov_money', name: 'Moov Money', prefix: '+225 01'),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Operateur Mobile Money',
            style: AppTextStyle.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _providers.map((p) {
              final selected = _selectedProvider == p.id;
              return Semantics(
                label: '${p.name}${selected ? ", selectionne" : ""}',
                child: GestureDetector(
                  onTap: () => setState(() => _selectedProvider = p.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.gold.withOpacity(0.12)
                          : context.colors.elevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.gold : Colors.transparent,
                      ),
                    ),
                    child: AppText(
                      p.name,
                      style: AppTextStyle.labelMedium,
                      color: selected ? AppColors.gold : context.colors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppInput(
            controller: _phoneController,
            label: 'Numero de telephone',
            hint: '+225 07 XX XX XX XX',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInput(
            controller: _amountController,
            label: 'Montant (XOF)',
            hint: '10 000',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.payments_outlined,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Deposer',
              variant: AppButtonVariant.primary,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(MobileMoneyDepositData(
        provider: _selectedProvider,
        phoneNumber: _phoneController.text,
        amountXof: double.tryParse(_amountController.text.replaceAll(' ', '')) ?? 0,
      ));
    }
  }
}

class MobileMoneyDepositData {
  final String provider;
  final String phoneNumber;
  final double amountXof;

  const MobileMoneyDepositData({
    required this.provider,
    required this.phoneNumber,
    required this.amountXof,
  });
}

class _MoMoProvider {
  final String id;
  final String name;
  final String prefix;

  const _MoMoProvider({
    required this.id,
    required this.name,
    required this.prefix,
  });
}
