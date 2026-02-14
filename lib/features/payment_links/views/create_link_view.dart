import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/payment_links/models/index.dart';
import 'package:usdc_wallet/features/payment_links/providers/payment_links_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class CreateLinkView extends ConsumerStatefulWidget {
  const CreateLinkView({super.key});

  @override
  ConsumerState<CreateLinkView> createState() => _CreateLinkViewState();
}

class _CreateLinkViewState extends ConsumerState<CreateLinkView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _expiryHours = 24;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.paymentLinks_createLink,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // Header
              AppText(
                l10n.paymentLinks_createDescription,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xl),

              // Amount Input
              AppInput(
                label: l10n.paymentLinks_amount,
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefix: const Text('CFA '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.common_requiredField;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return l10n.paymentLinks_invalidAmount;
                  }
                  if (amount < 100) {
                    return l10n.paymentLinks_minimumAmount;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),

              // Description Input
              AppInput(
                label: l10n.paymentLinks_description,
                controller: _descriptionController,
                maxLines: 3,
                hint: l10n.paymentLinks_descriptionHint,
              ),
              SizedBox(height: AppSpacing.lg),

              // Expiry Selection
              AppText(
                l10n.paymentLinks_expiresIn,
                variant: AppTextVariant.labelLarge,
              ),
              SizedBox(height: AppSpacing.sm),
              _buildExpiryOptions(l10n),
              SizedBox(height: AppSpacing.xl),

              // Info Card
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: context.colors.gold.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.colors.gold,
                      size: 24,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        l10n.paymentLinks_info,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Create Button
              AppButton(
                label: l10n.paymentLinks_createLink,
                onPressed: _handleCreate,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryOptions(AppLocalizations l10n) {
    final options = [
      (6, l10n.paymentLinks_6hours),
      (24, l10n.paymentLinks_24hours),
      (72, l10n.paymentLinks_3days),
      (168, l10n.paymentLinks_7days),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final hours = option.$1;
        final label = option.$2;
        final isSelected = _expiryHours == hours;

        return GestureDetector(
          onTap: () => setState(() => _expiryHours = hours),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? context.colors.gold : context.colors.container,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isSelected
                    ? context.colors.gold
                    : context.colors.textSecondary.withOpacity(0.2),
              ),
            ),
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: isSelected ? context.colors.canvas : context.colors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      final request = CreateLinkRequest(
        amount: amount,
        currency: 'XOF',
        description: description.isEmpty ? null : description,
        expiryHours: _expiryHours,
      );

      final link = await ref.read(paymentLinkActionsProvider).createLink(request);

      if (mounted && link != null) {
        context.go('/payment-links/created/${link.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              AppLocalizations.of(context)!.common_error,
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
