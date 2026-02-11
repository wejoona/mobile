import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/insights/models/spending_trend.dart';
import 'package:usdc_wallet/features/insights/models/insights_period.dart';

class SpendingLineChart extends StatefulWidget {
  final List<SpendingTrend> trends;
  final InsightsPeriod period;

  const SpendingLineChart({
    super.key,
    required this.trends,
    required this.period,
  });

  @override
  State<SpendingLineChart> createState() => _SpendingLineChartState();
}

class _SpendingLineChartState extends State<SpendingLineChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
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
    if (widget.trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = widget.trends.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LineChart(
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
            maxX: widget.trends.length.toDouble() - 1,
            minY: minY,
            maxY: maxY * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: widget.trends
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.amount * _animation.value))
                    .toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppColors.gold500,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.gold500,
                      strokeWidth: 3,
                      strokeColor: AppColors.obsidian,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold500.withValues(alpha: 0.2),
                      AppColors.gold500.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                shadow: Shadow(
                  color: AppColors.gold500.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => AppColors.slate,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipBorder: BorderSide(
                  color: AppColors.gold500.withValues(alpha: 0.3),
                  width: 1,
                ),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final trend = widget.trends[barSpot.x.toInt()];
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value.toInt() >= widget.trends.length || value < 0) {
      return const SizedBox.shrink();
    }

    final trend = widget.trends[value.toInt()];
    String label;

    switch (widget.period) {
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
      child: AppText(
        label,
        variant: AppTextVariant.bodySmall,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    return AppText(
      '\$${_formatAmount(value)}',
      variant: AppTextVariant.bodySmall,
      color: AppColors.textSecondary,
      textAlign: TextAlign.left,
    );
  }

  double _getBottomInterval() {
    if (widget.trends.length <= 7) return 1;
    if (widget.trends.length <= 14) return 2;
    return (widget.trends.length / 7).ceilToDouble();
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
