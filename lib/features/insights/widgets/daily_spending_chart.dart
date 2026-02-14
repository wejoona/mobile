import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/features/insights/models/spending_trend.dart';

/// Daily spending bar chart for week view
class DailySpendingChart extends StatefulWidget {
  final List<SpendingTrend> dailyTrends;
  final bool showComparison;

  const DailySpendingChart({
    super.key,
    required this.dailyTrends,
    this.showComparison = false,
  });

  @override
  State<DailySpendingChart> createState() => _DailySpendingChartState();
}

class _DailySpendingChartState extends State<DailySpendingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.dailyTrends.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = widget.dailyTrends.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                });
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => AppColors.slate,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final trend = widget.dailyTrends[groupIndex];
                  return BarTooltipItem(
                    '\$${trend.amount.toStringAsFixed(2)}\n${DateFormat('MMM d').format(trend.date)}',
                    AppTypography.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: _buildBottomTitle,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxY / 4,
                  reservedSize: 42,
                  getTitlesWidget: _buildLeftTitle,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: context.colors.borderSubtle,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: context.colors.border),
                left: BorderSide(color: context.colors.border),
              ),
            ),
            barGroups: _buildBarGroups(),
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.dailyTrends.asMap().entries.map((entry) {
      final index = entry.key;
      final trend = entry.value;
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: trend.amount,
            color: isTouched ? AppColors.gold400 : context.colors.gold,
            width: isTouched ? 24 : 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: (widget.dailyTrends.map((t) => t.amount).reduce((a, b) => a > b ? a : b)) * 1.2,
              color: AppColors.slate,
            ),
            gradient: isTouched
                ? LinearGradient(
                    colors: [
                      AppColors.gold400,
                      AppColors.gold600,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : null,
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value.toInt() >= widget.dailyTrends.length || value < 0) {
      return const SizedBox.shrink();
    }

    final trend = widget.dailyTrends[value.toInt()];
    final label = DateFormat('E').format(trend.date); // Mon, Tue, Wed

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        label.substring(0, 1), // First letter only
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    return Text(
      '\$${_formatAmount(value)}',
      style: AppTypography.bodySmall.copyWith(
        color: context.colors.textSecondary,
      ),
      textAlign: TextAlign.left,
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
