import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';

/// Run 379: Account deletion view with confirmation steps
class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({super.key});

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  bool _confirmed = false;
  bool _isDeleting = false;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: const AppText(
          'Supprimer mon compte',
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const AlertBanner(
            message: 'Attention: cette action est irreversible. '
                'Toutes vos donnees seront definitivement supprimees.',
            type: AlertVariant.error,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Que se passe-t-il quand vous supprimez votre compte:',
            style: AppTextStyle.labelLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConsequenceItem(
            text: 'Votre solde restant sera perdu',
            icon: Icons.account_balance_wallet_outlined,
          ),
          _ConsequenceItem(
            text: 'Historique des transactions supprime',
            icon: Icons.history,
          ),
          _ConsequenceItem(
            text: 'Impossible de recuperer votre compte',
            icon: Icons.no_accounts,
          ),
          _ConsequenceItem(
            text: 'Donnees KYC effacees sous 30 jours',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppInput(
            controller: _reasonController,
            label: 'Raison de suppression (optionnel)',
            hint: 'Dites-nous pourquoi vous partez...',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Semantics(
                label: 'Confirmer la suppression du compte',
                child: Checkbox(
                  value: _confirmed,
                  onChanged: (v) => setState(() => _confirmed = v ?? false),
                  activeColor: context.colors.error,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: const AppText(
                    'Je comprends que cette action est irreversible',
                    style: AppTextStyle.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Supprimer definitivement',
            variant: AppButtonVariant.danger,
            isLoading: _isDeleting,
            onPressed: _confirmed && !_isDeleting ? _deleteAccount : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Annuler',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/account/delete', data: {
        if (_reasonController.text.isNotEmpty) 'reason': _reasonController.text.trim(),
      });
      // Logout after successful account deletion request
      if (mounted) {
        ref.read(authProvider.notifier).logout();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de supprimer le compte: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }
}

class _ConsequenceItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const _ConsequenceItem({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: context.colors.error, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              text,
              style: AppTextStyle.bodyMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
