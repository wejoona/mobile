import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/typography.dart';
import '../models/spending_trend.dart';
import '../models/insights_period.dart';

class SpendingLineChart extends StatelessWidget {
  final List<SpendingTrend> trends;
  final InsightsPeriod period;

  const SpendingLineChart({
    super.key,
    required this.trends,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = trends.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.borderSubtle,
                  strokeWidth: 1,
                );
              },
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
                  interval: _getBottomInterval(),
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
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
                left: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            minX: 0,
            maxX: trends.length.toDouble() - 1,
            minY: minY,
            maxY: maxY * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: trends
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.amount))
                    .toList(),
                isCurved: true,
                color: AppColors.gold500,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.gold500,
                      strokeWidth: 2,
                      strokeColor: AppColors.obsidian,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.gold500.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => AppColors.slate,
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final trend = trends[barSpot.x.toInt()];
                    return LineTooltipItem(
                      '\$${trend.amount.toStringAsFixed(2)}\n${_formatDate(trend.date)}',
                      AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value.toInt() >= trends.length || value < 0) {
      return const SizedBox.shrink();
    }

    final trend = trends[value.toInt()];
    String label;

    switch (period) {
      case InsightsPeriod.week:
        label = DateFormat('E').format(trend.date); // Mon, Tue, etc.
        break;
      case InsightsPeriod.month:
        label = DateFormat('d').format(trend.date); // 1, 2, 3, etc.
        break;
      case InsightsPeriod.year:
        label = DateFormat('MMM').format(trend.date); // Jan, Feb, etc.
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    return Text(
      '\$${_formatAmount(value)}',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.left,
    );
  }

  double _getBottomInterval() {
    if (trends.length <= 7) return 1;
    if (trends.length <= 14) return 2;
    return (trends.length / 7).ceilToDouble();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
