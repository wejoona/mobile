import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Screen for creating a new sub-business
class CreateSubBusinessView extends ConsumerStatefulWidget {
  const CreateSubBusinessView({super.key});

  @override
  ConsumerState<CreateSubBusinessView> createState() =>
      _CreateSubBusinessViewState();
}

class _CreateSubBusinessViewState extends ConsumerState<CreateSubBusinessView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  SubBusinessType _selectedType = SubBusinessType.department;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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
          l10n.subBusiness_createTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // Name input
              AppInput(
                label: l10n.subBusiness_nameLabel,
                controller: _nameController,
                validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
              ),
              SizedBox(height: AppSpacing.md),

              // Description input
              AppInput(
                label: l10n.subBusiness_descriptionLabel,
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.md),

              // Type selector
              AppText(
                l10n.subBusiness_typeLabel,
                variant: AppTextVariant.bodyMedium,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: AppSpacing.sm),
              _buildTypeSelector(l10n),
              SizedBox(height: AppSpacing.xl),

              // Info card
              Container(
                decoration: BoxDecoration(
                  color: context.colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: context.colors.gold.withOpacity(0.2),
                  ),
                ),
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.colors.gold,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        l10n.subBusiness_createInfo,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Create button
              AppButton(
                label: l10n.subBusiness_createButton,
                onPressed: _handleCreate,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: SubBusinessType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.gold.withOpacity(0.2)
                  : context.colors.container,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? context.colors.gold
                    : context.colors.textSecondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForType(type),
                  size: 16,
                  color: isSelected ? context.colors.gold : context.colors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                AppText(
                  _getTypeLabel(type, l10n),
                  variant: AppTextVariant.bodyMedium,
                  color: isSelected ? context.colors.gold : context.colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForType(SubBusinessType type) {
    switch (type) {
      case SubBusinessType.department:
        return Icons.business_center;
      case SubBusinessType.branch:
        return Icons.store;
      case SubBusinessType.subsidiary:
        return Icons.corporate_fare;
      case SubBusinessType.team:
        return Icons.groups;
    }
  }

  String _getTypeLabel(SubBusinessType type, AppLocalizations l10n) {
    switch (type) {
      case SubBusinessType.department:
        return l10n.subBusiness_typeDepartment;
      case SubBusinessType.branch:
        return l10n.subBusiness_typeBranch;
      case SubBusinessType.subsidiary:
        return l10n.subBusiness_typeSubsidiary;
      case SubBusinessType.team:
        return l10n.subBusiness_typeTeam;
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final subBusiness = await ref.read(subBusinessProvider.notifier).createSubBusiness(
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            type: _selectedType,
          );

      if (mounted) {
        if (subBusiness != null) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.subBusiness_createSuccess),
              backgroundColor: context.colors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error_generic),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
