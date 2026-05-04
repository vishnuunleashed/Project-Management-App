import 'dart:math';

import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/dashboard/dashboard_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/utils/routes.dart';


class SummaryPieChartWidget extends StatelessWidget {
  const SummaryPieChartWidget({super.key});

  AllObservationAndSupportStatus _statusForIndex(int index) {
    switch (index) {
      case 0:
        return AllObservationAndSupportStatus.opened;
      case 1:
        return AllObservationAndSupportStatus.delayed;
      case 2:
        return AllObservationAndSupportStatus.closed;
      default:
        return AllObservationAndSupportStatus.opened;
    }
  }

  void _onSectionTap(BuildContext context, DashBoardProvider provider, int index) {
    final status = _statusForIndex(index);

    if (provider.dashBoardTabs[provider.currentTabIndex] == 'Support Requests') {
      GoRouter.of(context).pushNamed(
        AppRoutes.allSupportRequestScreen,
        extra: {
          'bottomBarStatus': status,
          'projectId': provider.projectId,
          'isCritical': provider.isCritical,
          'isFromPieChart' : true

        },
      );
    } else {
      GoRouter.of(context).pushNamed(
        AppRoutes.allObservationListScreen,
        extra: {
          'bottomBarStatus': status,
          'projectId': provider.projectId,
          'isFromPieChart' : true
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return BaseStatelessConsumer<DashBoardProvider>(
      provider: dashBoardProvider,
      builder: (context, provider, child) {
        return Center(
          child: SizedBox(
            height: 250,
            width: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(250, 250),
                  painter: ChartLabelsPainter(
                    colors: provider.chartColors,
                    labels: provider.chartLabels,
                    values: provider.chartValues,
                    textFontColor: Theme.of(context).colorScheme.primary,
                    labelStyle: Theme.of(context).textTheme.labelLarge!
                  ),
                ),
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 50,
                    sectionsSpace: 0,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                        if (event is FlTapUpEvent) {
                          final touchedIndex =
                              response?.touchedSection?.touchedSectionIndex;
                          if (touchedIndex != null && touchedIndex >= 0) {
                            _onSectionTap(context, provider, touchedIndex);
                          }
                        }
                      },
                    ),
                    sections: List.generate(provider.chartValues.length, (i) {
                      return PieChartSectionData(
                        value: provider.chartValues[i],
                        color: provider.chartColors[i],
                        radius: 50,
                        title: '',
                      );
                    }),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (provider.dashBoardList.isNotEmpty &&
                    provider.dashBoardList.first.summaryJson?.isNotEmpty == true)
                    ? (provider.dashBoardList.first.summaryJson!.first.totalCount ?? 0).toString()
                    : "0",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChartLabelsPainter extends CustomPainter {
  final List<Color> colors;
  final List<String> labels;
  final List<double> values;
  final Color textFontColor;
  final TextStyle labelStyle;

  ChartLabelsPainter({
    required this.colors,
    required this.labels,
    required this.values,
    required this.textFontColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 40;
    final total = values.fold<double>(0, (a, b) => a + b);

    // ── 1. First pass: compute raw anchor points ──────────────────────────
    final List<_LabelData> labelData = [];
    double startAngle = -90;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) {
        startAngle += 0;
        continue;
      }
      final sweepAngle = (values[i] / total) * 360;
      final midAngle = startAngle + sweepAngle / 2;
      final radians = midAngle * pi / 180;

      final startPoint = Offset(
        center.dx + radius * cos(radians),
        center.dy + radius * sin(radians),
      );

// After
      final endPoint = Offset(
        center.dx + (radius + 35) * cos(radians),  // +15 more
        center.dy + (radius + 60) * sin(radians),  // +20 more
      );
      final isRightSide = cos(radians) >= 0;

      labelData.add(_LabelData(
        index: i,
        radians: radians,
        startPoint: startPoint,
        endPoint: endPoint,
        isRightSide: isRightSide,
        anchorY: endPoint.dy, // mutable Y we will adjust
      ));

      startAngle += sweepAngle;
    }

    // ── 2. Collision resolution: separate overlapping labels ──────────────
    const double labelBlockHeight = 28.0; // approx label + value + gap
    const double minSpacing = labelBlockHeight + 4;

    // Sort by Y so we process top-to-bottom
    final sorted = [...labelData]..sort((a, b) => a.anchorY.compareTo(b.anchorY));

    // Forward pass: push down
    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final overlap = (prev.anchorY + minSpacing) - curr.anchorY;
      if (overlap > 0) {
        curr.anchorY += overlap;
      }
    }

    // Backward pass: push up (handles cascaded push beyond chart bounds)
    for (int i = sorted.length - 2; i >= 0; i--) {
      final next = sorted[i + 1];
      final curr = sorted[i];
      final overlap = (curr.anchorY + minSpacing) - next.anchorY;
      if (overlap > 0) {
        curr.anchorY -= overlap;
      }
    }

    // ── 3. Second pass: draw everything with adjusted Y ───────────────────
    final labelPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final valuePainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    final paintLine = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final d in labelData) {
      final color = colors[d.index];

      // Adjusted horizontal anchor
      final horizontalEnd = Offset(
        d.endPoint.dx + (d.isRightSide ? 40 : -40),
        d.anchorY, // ← adjusted Y
      );

      paintLine.color = color;

      // Leader line: slice edge → elbow
      canvas.drawLine(d.startPoint, d.endPoint, paintLine);

      // Elbow → adjusted horizontal tip
      canvas.drawLine(d.endPoint, horizontalEnd, paintLine);

      // Label
      labelPainter.text = TextSpan(text: labels[d.index], style: labelStyle);
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          horizontalEnd.dx - labelPainter.width / 2,
          horizontalEnd.dy - labelPainter.height - 2,
        ),
      );

      // Value
      valuePainter.text = TextSpan(
        text: values[d.index].toInt().toString(),
        style: labelStyle.copyWith(color: color, fontWeight: FontWeight.bold),
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
          horizontalEnd.dx - valuePainter.width / 2,
          horizontalEnd.dy + 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Helper data class ──────────────────────────────────────────────────────
class _LabelData {
  final int index;
  final double radians;
  final Offset startPoint;
  final Offset endPoint;
  final bool isRightSide;
  double anchorY; // adjusted during collision resolution

  _LabelData({
    required this.index,
    required this.radians,
    required this.startPoint,
    required this.endPoint,
    required this.isRightSide,
    required this.anchorY,
  });
}