import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/rate_point.dart';

class RateChart extends StatelessWidget {
  const RateChart({super.key, required this.points});

  final List<RatePoint> points;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final values = points.map((e) => e.value);
    final lowest = values.reduce((a, b) => a < b ? a : b);
    final highest = values.reduce((a, b) => a > b ? a : b);

    // Pad the Y range so the line never touches the edges, and handle a
    // perfectly flat series.
    final spread = highest - lowest;
    final padding = spread == 0 ? highest.abs() * 0.01 + 0.0001 : spread * 0.15;
    final minY = lowest - padding;
    final maxY = highest + padding;

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final lastIndex = (points.length - 1).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: lastIndex,
        minY: minY,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: p.border,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 58,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    Formatters.rate(value),
                    style: TextStyle(color: p.muted, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: lastIndex / 2,
              getTitlesWidget: (value, meta) {
                final index = value.round().clamp(0, points.length - 1);
                // bottomTitles ke andar
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    Formatters.shortDate(points[index].date),
                    style: TextStyle(color: p.muted, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary,
            getTooltipItems: (touched) => [
              for (final spot in touched)
                LineTooltipItem(
                  '${Formatters.rate(spot.y)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: Formatters.shortDate(
                        points[spot.x.round().clamp(0, points.length - 1)].date,
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.28),
                  AppColors.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
