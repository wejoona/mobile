import 'package:flutter/material.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/components/primitives/app_text.dart';
import '../models/top_recipient.dart';

/// Horizontal bar chart for top recipients
class TopRecipientsChart extends StatefulWidget {
  final List<TopRecipient> recipients;

  const TopRecipientsChart({
    super.key,
    required this.recipients,
  });

  @override
  State<TopRecipientsChart> createState() => _TopRecipientsChartState();
}

class _TopRecipientsChartState extends State<TopRecipientsChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.recipients.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get max amount for scaling
    final maxAmount = widget.recipients.first.totalSent;

    return Column(
      children: widget.recipients.asMap().entries.map((entry) {
        final index = entry.key;
        final recipient = entry.value;
        final isTouched = index == _touchedIndex;
        final barPercentage = (recipient.totalSent / maxAmount) * 100;

        return GestureDetector(
          onTapDown: (_) => setState(() => _touchedIndex = index),
          onTapUp: (_) => setState(() => _touchedIndex = -1),
          onTapCancel: () => setState(() => _touchedIndex = -1),
          child: Container(
            margin: EdgeInsets.only(bottom: index < widget.recipients.length - 1 ? AppSpacing.md : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and amount header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Rank badge
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: index < 3
                                  ? AppColors.gold500.withValues(alpha: 0.2)
                                  : AppColors.slate,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AppText(
                                '${index + 1}',
                                variant: AppTextVariant.bodySmall,
                                color: index < 3 ? AppColors.gold500 : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              recipient.name,
                              variant: AppTextVariant.bodyMedium,
                              color: isTouched ? AppColors.gold500 : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppText(
                      '\$${recipient.totalSent.toStringAsFixed(2)}',
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Bar container
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.slate,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Animated bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        width: (barPercentage / 100) * MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isTouched
                                ? [AppColors.gold400, AppColors.gold600]
                                : [AppColors.gold500, AppColors.gold700],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isTouched
                              ? [
                                  BoxShadow(
                                    color: AppColors.gold500.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Transaction count
                AppText(
                  '${recipient.transactionCount} transactions • ${recipient.percentage.toStringAsFixed(1)}%',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
