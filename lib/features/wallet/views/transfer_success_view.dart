import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

class TransferSuccessView extends StatefulWidget {
  const TransferSuccessView({
    required this.amount,
    required this.recipient,
    required this.transactionId,
    super.key,
    this.note,
  });

  final double amount;
  final String recipient;
  final String transactionId;
  final String? note;

  @override
  State<TransferSuccessView> createState() => _TransferSuccessViewState();
}

class _TransferSuccessViewState extends State<TransferSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    // Trigger haptic feedback
    unawaited(HapticFeedback.mediumImpact());

    // Start animation
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      AppCard(
                        variant: AppCardVariant.goldAccent,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppRadius.lg,
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: context.colors.success.withValues(
                                      alpha: colors.isDark ? 0.16 : 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 28,
                                    color: context.colors.success,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppText(
                              l10n.transfer_successTitle,
                              variant: AppTextVariant.titleLarge,
                              color: colors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            AppText(
                              formatUsdc(widget.amount),
                              variant: AppTextVariant.headlineMedium,
                              color: colors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            AppText(
                              widget.recipient,
                              color: colors.textSecondary,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        borderRadius: AppRadius.lg,
                        child: Column(
                          children: [
                            _DetailRow(
                              label: l10n.transactions_transactionId,
                              value: _truncateId(widget.transactionId),
                              canCopy: true,
                              fullValue: widget.transactionId,
                              colors: colors,
                              l10n: l10n,
                            ),
                            Divider(color: context.colors.borderSubtle),
                            _DetailRow(
                              label: l10n.transactions_status,
                              value: l10n.transactions_completed,
                              valueColor: context.colors.success,
                              colors: colors,
                              l10n: l10n,
                            ),
                            if (widget.note != null &&
                                widget.note!.trim().isNotEmpty) ...[
                              Divider(color: context.colors.borderSubtle),
                              _DetailRow(
                                label: l10n.common_note,
                                value: widget.note!,
                                colors: colors,
                                l10n: l10n,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      label: l10n.action_shareReceipt,
                      onPressed: () => _shareReceipt(l10n),
                      variant: AppButtonVariant.secondary,
                      isFullWidth: true,
                      icon: Icons.share,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.common_done,
                      onPressed: () => context.fsmGo('/home'),
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateId(String id) {
    if (id.length <= 12) {
      return id;
    }
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  void _shareReceipt(AppLocalizations l10n) {
    final receipt =
        '''
Korido Transfer Receipt

Amount: ${formatUsdc(widget.amount)}
To: ${widget.recipient}
Transaction ID: ${widget.transactionId}
Status: ${l10n.transactions_completed}
${widget.note != null && widget.note!.trim().isNotEmpty ? 'Note: ${widget.note}' : ''}

Thank you for using Korido!
''';

    unawaited(
      SharePlus.instance.share(
        ShareParams(text: receipt, title: 'Korido Transfer Receipt'),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.l10n,
    this.valueColor,
    this.canCopy = false,
    this.fullValue,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final AppLocalizations l10n;
  final Color? valueColor;
  final bool canCopy;
  final String? fullValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: AppText(label, color: colors.textSecondary)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: AppText(
              value,
              color: valueColor ?? colors.textPrimary,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canCopy) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                unawaited(
                  Clipboard.setData(ClipboardData(text: fullValue ?? value)),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.action_copiedToClipboard),
                    backgroundColor: context.colors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Icon(Icons.copy, size: 16, color: context.colors.gold),
            ),
          ],
        ],
      ),
    );
  }
}
