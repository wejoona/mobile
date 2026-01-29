import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/sub_business_provider.dart';
import '../models/sub_business.dart';

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
      backgroundColor: AppColors.obsidian,
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
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.gold500.withOpacity(0.2),
                  ),
                ),
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.gold500,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        l10n.subBusiness_createInfo,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
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
                  ? AppColors.gold500.withOpacity(0.2)
                  : AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold500
                    : AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForType(type),
                  size: 16,
                  color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                AppText(
                  _getTypeLabel(type, l10n),
                  variant: AppTextVariant.bodyMedium,
                  color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
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
              backgroundColor: AppColors.successBase,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.error_generic),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
