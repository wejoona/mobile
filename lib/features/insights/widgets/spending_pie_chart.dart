import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/typography.dart';
import '../models/spending_category.dart';

class SpendingPieChart extends StatefulWidget {
  final List<SpendingCategory> categories;

  const SpendingPieChart({
    super.key,
    required this.categories,
  });

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
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
                _touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: _buildSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final fontSize = isTouched ? 16.0 : 14.0;

      return PieChartSectionData(
        color: category.color,
        value: category.percentage,
        title: '${category.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: AppTypography.bodyMedium.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: category.color, width: 2),
                ),
                child: Text(
                  category.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }
}
