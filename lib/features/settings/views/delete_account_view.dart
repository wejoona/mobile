import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

const _deleteConfirmationPhrase = 'DELETE';

class DeleteAccountView extends ConsumerStatefulWidget {
  const DeleteAccountView({super.key});

  @override
  ConsumerState<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends ConsumerState<DeleteAccountView> {
  final _confirmationController = TextEditingController();
  bool _isDeleting = false;
  String? _error;

  bool get _canDelete =>
      _confirmationController.text.trim().toUpperCase() ==
          _deleteConfirmationPhrase &&
      !_isDeleting;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.delete_accountTitle,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: _isDeleting
              ? null
              : () => context.fsmSafePop(fallbackRoute: '/settings/security'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          AlertBanner(
            message: l10n.delete_warningMessage,
            type: AlertVariant.error,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            l10n.delete_consequencesTitle,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConsequenceItem(
            text: l10n.delete_consequenceBalance,
            icon: Icons.account_balance_wallet_outlined,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceHistory,
            icon: Icons.history,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceIrreversible,
            icon: Icons.no_accounts,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceKyc,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppCard(
            variant: AppCardVariant.flat,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.security_deleteAccountTitle,
                  variant: AppTextVariant.titleSmall,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  l10n.delete_confirmInstruction(_deleteConfirmationPhrase),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                AppInput(
                  controller: _confirmationController,
                  label: _deleteConfirmationPhrase,
                  hint: _deleteConfirmationPhrase,
                  enabled: !_isDeleting,
                  onChanged: (_) => setState(() => _error = null),
                  error: _error,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.security_delete,
            variant: AppButtonVariant.danger,
            isLoading: _isDeleting,
            onPressed: _canDelete ? _deactivateAccount : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.common_cancel,
            variant: AppButtonVariant.ghost,
            onPressed: _isDeleting
                ? null
                : () => context.fsmSafePop(fallbackRoute: '/settings/security'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateAccount() async {
    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      await ref.read(userServiceProvider).deactivateAccount();
      if (!mounted) {
        return;
      }
      await ref.read(authProvider.notifier).clearLocalSession();
      if (!mounted) {
        return;
      }
      context.fsmGo('/login');
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDeleting = false;
        _error = AppLocalizations.of(
          context,
        )!.common_errorFormat(error.toString());
      });
    }
  }
}

class _ConsequenceItem extends StatelessWidget {
  const _ConsequenceItem({required this.text, required this.icon});

  final String text;
  final IconData icon;

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
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
