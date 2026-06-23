import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

class DepositStatusScreen extends ConsumerWidget {
  const DepositStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(depositProvider);
    final response = state.response;
    final hasActiveDeposit = state.activeDepositId != null || response != null;

    if (!hasActiveDeposit && state.step != DepositFlowStep.failed) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: _MissingDepositStatus(
            l10n: l10n,
            colors: colors,
            onStartDeposit: () => _handleTryAgain(ref, context),
            onGoHome: () => _handleGoHome(ref, context),
          ),
        ),
      );
    }

    final status = _getDepositStatus(state);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(child: _buildStatusIcon(status, colors)),
              const SizedBox(height: AppSpacing.xl),
              AppText(
                _getStatusTitle(context, status, l10n),
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                _getStatusSubtitle(context, status, l10n),
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (status == _DepositStatus.completed && response != null) ...[
                _CompletedDepositCard(state: state, colors: colors),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (status == _DepositStatus.failed && state.error != null) ...[
                _FailedDepositCard(
                  error: state.error ?? l10n.common_unknownError,
                  l10n: l10n,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (status == _DepositStatus.statusUnknown) ...[
                _StatusUnknownDepositCard(message: state.error, colors: colors),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (status == _DepositStatus.processing) ...[
                _ProcessingDepositCard(l10n: l10n, colors: colors),
                const SizedBox(height: AppSpacing.xl),
              ],
              _buildActions(status, ref, context, l10n, colors),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
    _DepositStatus status,
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppButton(
        label: status == _DepositStatus.processing
            ? l10n.action_checkStatus
            : l10n.action_done,
        onPressed: () => _handlePrimaryAction(status, ref, context),
        isFullWidth: true,
      ),
      if (status == _DepositStatus.failed) ...[
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.action_tryAgain,
          variant: AppButtonVariant.secondary,
          onPressed: () => _handleTryAgain(ref, context),
          isFullWidth: true,
        ),
      ],
      if (status != _DepositStatus.completed) ...[
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => _handleGoHome(ref, context),
          child: AppText(
            l10n.action_backToHome,
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
        ),
      ],
    ],
  );

  Widget _buildStatusIcon(_DepositStatus status, ThemeColors colors) {
    final (backgroundColor, iconColor, iconData) = switch (status) {
      _DepositStatus.completed => (
        colors.success.withValues(alpha: 0.1),
        colors.success,
        Icons.check_circle,
      ),
      _DepositStatus.failed => (
        colors.error.withValues(alpha: 0.1),
        colors.error,
        Icons.error,
      ),
      _DepositStatus.statusUnknown => (
        colors.warning.withValues(alpha: 0.12),
        colors.warningText,
        Icons.schedule_send_outlined,
      ),
      _DepositStatus.processing => (
        colors.gold.withValues(alpha: 0.1),
        colors.gold,
        Icons.schedule,
      ),
    };

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: Icon(iconData, size: 64, color: iconColor),
    );
  }

  _DepositStatus _getDepositStatus(DepositState state) {
    if (state.step == DepositFlowStep.completed) {
      return _DepositStatus.completed;
    }
    if (state.step == DepositFlowStep.failed) {
      return _DepositStatus.failed;
    }
    if (state.step == DepositFlowStep.statusUnknown) {
      return _DepositStatus.statusUnknown;
    }
    return _DepositStatus.processing;
  }

  String _getStatusTitle(
    BuildContext context,
    _DepositStatus status,
    AppLocalizations l10n,
  ) => switch (status) {
    _DepositStatus.completed => l10n.deposit_successTitle,
    _DepositStatus.failed => l10n.deposit_failedTitle,
    _DepositStatus.statusUnknown => _localizedDepositCopy(
      context,
      en: 'Deposit still pending',
      fr: 'Dépôt encore en attente',
    ),
    _DepositStatus.processing => l10n.deposit_processingTitle,
  };

  String _getStatusSubtitle(
    BuildContext context,
    _DepositStatus status,
    AppLocalizations l10n,
  ) => switch (status) {
    _DepositStatus.completed => l10n.deposit_successDesc,
    _DepositStatus.failed => l10n.deposit_failedDesc,
    _DepositStatus.statusUnknown => _localizedDepositCopy(
      context,
      en: 'Korido accepted the deposit request, but the final provider status is taking longer than expected.',
      fr: 'Korido a accepté la demande de dépôt, mais le statut final du fournisseur prend plus de temps que prévu.',
    ),
    _DepositStatus.processing => l10n.deposit_processingSubtitle,
  };

  void _handlePrimaryAction(
    _DepositStatus status,
    WidgetRef ref,
    BuildContext context,
  ) {
    switch (status) {
      case _DepositStatus.completed:
      case _DepositStatus.failed:
      case _DepositStatus.statusUnknown:
        _handleGoHome(ref, context);
        break;
      case _DepositStatus.processing:
        unawaited(ref.read(depositProvider.notifier).checkStatus());
        break;
    }
  }

  void _handleTryAgain(WidgetRef ref, BuildContext context) {
    ref.read(depositProvider.notifier).reset();
    context.fsmGo('/deposit/amount');
  }

  void _handleGoHome(WidgetRef ref, BuildContext context) {
    ref.read(depositProvider.notifier).reset();
    context.fsmGo('/home');
  }
}

class _CompletedDepositCard extends StatelessWidget {
  const _CompletedDepositCard({
    required DepositState state,
    required ThemeColors colors,
  }) : _state = state,
       _colors = colors;

  final DepositState _state;
  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final response = _state.response;

    if (response == null) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _AmountColumn(
                  label: l10n.deposit_deposited,
                  alignment: Alignment.centerLeft,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  amount: _formatSourceAmount(_state, response.amount),
                  color: _colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.arrow_forward, color: _colors.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _AmountColumn(
                  label: l10n.deposit_received,
                  alignment: Alignment.centerRight,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  amount: formatUsdc(
                    _state.amountUSD ?? response.convertedAmount ?? 0,
                  ),
                  color: _colors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: _colors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.check_circle, color: _colors.success, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  l10n.deposit_balanceUpdated,
                  color: _colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatSourceAmount(DepositState state, double fallbackAmount) {
  final currency = (state.sourceCurrency ?? 'XOF').toUpperCase();
  if (currency == 'USD') {
    return '\$${(state.amountUSD ?? 0).toStringAsFixed(2)}';
  }
  return formatXof(state.amountXOF ?? fallbackAmount);
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required String label,
    required String amount,
    required Color color,
    required Alignment alignment,
    required CrossAxisAlignment crossAxisAlignment,
  }) : _label = label,
       _amount = amount,
       _color = color,
       _alignment = alignment,
       _crossAxisAlignment = crossAxisAlignment;

  final String _label;
  final String _amount;
  final Color _color;
  final Alignment _alignment;
  final CrossAxisAlignment _crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: _crossAxisAlignment,
      children: [
        AppText(
          _label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Align(
          alignment: _alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: _alignment,
            child: AmountText.fromText(_amount, color: _color),
          ),
        ),
      ],
    );
  }
}

class _FailedDepositCard extends StatelessWidget {
  const _FailedDepositCard({
    required String error,
    required AppLocalizations l10n,
    required ThemeColors colors,
  }) : _error = error,
       _l10n = l10n,
       _colors = colors;

  final String _error;
  final AppLocalizations _l10n;
  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(Icons.error_outline, color: _colors.error, size: 24),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppText(
            _l10n.deposit_errorReason(_error),
            color: _colors.errorText,
          ),
        ),
      ],
    ),
  );
}

class _ProcessingDepositCard extends StatelessWidget {
  const _ProcessingDepositCard({
    required AppLocalizations l10n,
    required ThemeColors colors,
  }) : _l10n = l10n,
       _colors = colors;

  final AppLocalizations _l10n;
  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: _colors.gold),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppText(
            _l10n.deposit_processingDesc,
            color: _colors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _StatusUnknownDepositCard extends StatelessWidget {
  const _StatusUnknownDepositCard({
    required String? message,
    required ThemeColors colors,
  }) : _message = message,
       _colors = colors;

  final String? _message;
  final ThemeColors _colors;

  @override
  Widget build(BuildContext context) => AppCard(
    backgroundColor: _colors.warningBg,
    borderColor: _colors.warning.withValues(alpha: 0.24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: _colors.warningText, size: 24),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppText(
            _message ??
                _localizedDepositCopy(
                  context,
                  en: 'Please check your transaction history before starting another deposit.',
                  fr: 'Vérifiez votre historique avant de lancer un autre dépôt.',
                ),
            color: _colors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _MissingDepositStatus extends StatelessWidget {
  const _MissingDepositStatus({
    required AppLocalizations l10n,
    required ThemeColors colors,
    required VoidCallback onStartDeposit,
    required VoidCallback onGoHome,
  }) : _l10n = l10n,
       _colors = colors,
       _onStartDeposit = onStartDeposit,
       _onGoHome = onGoHome;

  final AppLocalizations _l10n;
  final ThemeColors _colors;
  final VoidCallback _onStartDeposit;
  final VoidCallback _onGoHome;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.screenPadding),
    child: Center(
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: _colors.gold),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              _l10n.deposit_noDepositData,
              variant: AppTextVariant.titleMedium,
              color: _colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _l10n.deposit_amount,
              onPressed: _onStartDeposit,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: _l10n.action_backToHome,
              variant: AppButtonVariant.secondary,
              onPressed: _onGoHome,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    ),
  );
}

String _localizedDepositCopy(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}

enum _DepositStatus { completed, failed, statusUnknown, processing }
