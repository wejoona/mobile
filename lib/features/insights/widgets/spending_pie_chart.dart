import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/insights/models/spending_category.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

class SpendingPieChart extends StatefulWidget {
  final List<SpendingCategory> categories;

  const SpendingPieChart({super.key, required this.categories});

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated pie chart
        AspectRatio(
          aspectRatio: 1.3,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 65,
                  sections: _buildSections(context),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
              );
            },
          ),
        ),

        // Center total display
        if (_touchedIndex >= 0 && _touchedIndex < widget.categories.length)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                widget.categories[_touchedIndex].name,
                variant: AppTextVariant.bodySmall,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              AmountText.fromText(
                formatXof(widget.categories[_touchedIndex].amount),
                size: AmountTextSize.small,
                color: context.colors.gold,
              ),
            ],
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 75.0 : 65.0;
      final color = _chartColor(context, index);

      return PieChartSectionData(
        color: color.withValues(alpha: isTouched ? 1 : 0.86),
        value: category.percentage * _animation.value,
        title: '',
        radius: radius,
        borderSide: isTouched
            ? BorderSide(
                color: context.colors.gold.withValues(alpha: 0.5),
                width: 2,
              )
            : BorderSide.none,
      );
    }).toList();
  }

  Color _chartColor(BuildContext context, int index) {
    final colors = context.colors;
    final palette = [
      colors.gold,
      colors.infoText,
      colors.successText,
      colors.warningText,
      colors.textSecondary,
    ];
    return palette[index % palette.length];
  }
}
