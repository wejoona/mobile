import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class TransferSuccessView extends StatefulWidget {
  const TransferSuccessView({
    super.key,
    required this.amount,
    required this.recipient,
    required this.transactionId,
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

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),

              // Success animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.successBase.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.successBase,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Success message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    AppText(
                      'Transfer Successful!',
                      variant: AppTextVariant.headlineMedium,
                      color: colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppText(
                      'You sent \$${widget.amount.toStringAsFixed(2)} to',
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      widget.recipient,
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Transaction details card
              FadeTransition(
                opacity: _fadeAnimation,
                child: AppCard(
                  variant: AppCardVariant.subtle,
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Transaction ID',
                        value: _truncateId(widget.transactionId),
                        canCopy: true,
                        fullValue: widget.transactionId,
                        colors: colors,
                      ),
                      Divider(color: colors.borderSubtle),
                      _DetailRow(
                        label: 'Amount',
                        value: '\$${widget.amount.toStringAsFixed(2)}',
                        colors: colors,
                      ),
                      Divider(color: colors.borderSubtle),
                      _DetailRow(
                        label: 'Status',
                        value: 'Completed',
                        valueColor: AppColors.successBase,
                        colors: colors,
                      ),
                      if (widget.note != null) ...[
                        Divider(color: colors.borderSubtle),
                        _DetailRow(
                          label: 'Note',
                          value: widget.note!,
                          colors: colors,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    AppButton(
                      label: 'Share Receipt',
                      onPressed: _shareReceipt,
                      variant: AppButtonVariant.secondary,
                      isFullWidth: true,
                      icon: Icons.share,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Done',
                      onPressed: () => context.go('/home'),
                      variant: AppButtonVariant.primary,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _truncateId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  void _shareReceipt() {
    final receipt = '''
JoonaPay Transfer Receipt

Amount: \$${widget.amount.toStringAsFixed(2)}
To: ${widget.recipient}
Transaction ID: ${widget.transactionId}
Status: Completed
${widget.note != null ? 'Note: ${widget.note}' : ''}

Thank you for using JoonaPay!
''';

    Share.share(receipt, subject: 'JoonaPay Transfer Receipt');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
    this.canCopy = false,
    this.fullValue,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final Color? valueColor;
  final bool canCopy;
  final String? fullValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          Row(
            children: [
              AppText(
                value,
                variant: AppTextVariant.bodyMedium,
                color: valueColor ?? colors.textPrimary,
              ),
              if (canCopy) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: fullValue ?? value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        backgroundColor: AppColors.successBase,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: colors.gold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
