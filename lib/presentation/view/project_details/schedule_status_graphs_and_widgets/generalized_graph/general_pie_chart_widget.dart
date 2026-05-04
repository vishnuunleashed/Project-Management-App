import 'dart:math';
import 'package:base/presentation/theme_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GeneralPieChart extends StatefulWidget {
  final List<Map<String, Object>> data;
  final String titleKey;
  final String labelKey;
  final String valueKey;
  final String colorKey;

  /// UI customizations
  final double chartSize;
  final double pieRadius;
  final double centerSpaceRadius;
  final double leaderLinePadding;
  final Function(Map<String, Object> data, int index)? onSectionTap;
  const GeneralPieChart({
    super.key,
    required this.data,
    this.titleKey = 'title',
    this.labelKey = 'label',
    this.valueKey = 'value',
    this.colorKey = 'color',
    this.chartSize = 250,
    this.pieRadius = 50,
    this.centerSpaceRadius = 50,
    this.leaderLinePadding = 40,
    this.onSectionTap,
  });

  @override
  State<GeneralPieChart> createState() => _GeneralPieChartState();
}

class _GeneralPieChartState extends State<GeneralPieChart> {
  int? touchedIndex;
  double getTotal() {
    return widget.data.fold<double>(
      0,
          (sum, element) => sum + (element[widget.valueKey] as double),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final totalValue = getTotal();
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 0.5,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            width: 0.5,
            color: Theme.of(context).cardColor,
          ),
        ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TITLE ----------
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 4.0),
              child: Text(
                widget.data.first[widget.titleKey]?.toString() ?? "",
                style: theme.textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 60),

            // ---------- PIE CHART ----------
            Center(
              child: SizedBox(
                height: widget.chartSize,
                width: widget.chartSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ---- Custom Label Painter ----
                    CustomPaint(
                      size: Size(widget.chartSize, widget.chartSize),
                      painter: _PieLabelsPainter(
                        data: widget.data,
                        labelKey: widget.labelKey,
                        valueKey: widget.valueKey,
                        colorKey: widget.colorKey,
                        textColor: theme.colorScheme.primary,
                        padding: widget.leaderLinePadding,
                        labelStyle: theme.textTheme.labelLarge!,
                      ),
                    ),

                    // ---- Pie Chart ----
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: widget.centerSpaceRadius,
                        sectionsSpace: 0,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                            setState(() {
                              if (response != null &&
                                  response.touchedSection != null &&
                                  event is! FlPanEndEvent &&
                                  event is! FlPointerExitEvent) {
                                touchedIndex = response.touchedSection!.touchedSectionIndex;

                                // Handle tap event
                                if (event is FlTapUpEvent && widget.onSectionTap != null) {
                                  final index = response.touchedSection!.touchedSectionIndex;
                                  if (index >= 0 && index < widget.data.length) {
                                    widget.onSectionTap!(widget.data[index], index);
                                  }
                                }
                              } else {
                                touchedIndex = null;
                              }
                            });
                          },
                        ),
                        sections: List.generate(widget.data.length, (i) {
                          return PieChartSectionData(
                            value: widget.data[i][widget.valueKey] as double,
                            color: widget.data[i][widget.colorKey] as Color,
                            radius: widget.pieRadius,
                            title: '',
                          );
                        }),
                      ),
                    ),

                    // ---- CENTER TOTAL TEXT ----
                    Text(
                      totalValue.toInt().toString(),
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // ---------- LEGEND ----------
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: widget.data.map((e) {
                  return _legendItem(
                    context,
                    e[widget.labelKey].toString(),
                    e[widget.colorKey] as Color,
                    e[widget.valueKey] as double,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _legendItem(
    BuildContext context,
    String text,
    Color color,
    double value,
  ) {
    if (value <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
class _PieLabelsPainter extends CustomPainter {
  final List<Map<String, Object>> data;
  final String labelKey;
  final String valueKey;
  final String colorKey;
  final Color textColor;
  final TextStyle labelStyle;
  final double padding;

  _PieLabelsPainter({
    required this.data,
    required this.labelKey,
    required this.valueKey,
    required this.colorKey,
    required this.textColor,
    required this.labelStyle,
    this.padding = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - padding;
    final total = data.fold<double>(
      0,
          (sum, e) => sum + (e[valueKey] as double),
    );

    // ── 1. First pass: compute raw anchor points ──────────────────────────
    final List<_LabelData> labelDataList = [];
    double startAngle = -90;

    for (int i = 0; i < data.length; i++) {
      final value = data[i][valueKey] as double;
      if (value <= 0) {
        continue;
      }

      final sweepAngle = (value / total) * 360;
      final angle = startAngle + sweepAngle / 2;
      final radians = angle * pi / 180;
      final rightSide = cos(radians) >= 0;

      final start = Offset(
        center.dx + radius * cos(radians),
        center.dy + radius * sin(radians),
      );

      final mid = Offset(
        center.dx + (radius + 35) * cos(radians),
        center.dy + (radius + 60) * sin(radians),
      );

      final end = mid.translate(rightSide ? 40 : -40, 0);

      labelDataList.add(_LabelData(
        index: i,
        start: start,
        mid: mid,
        end: end,
        anchorY: mid.dy,
        rightSide: rightSide,
      ));

      startAngle += sweepAngle;
    }

    // ── 2. Collision resolution ───────────────────────────────────────────
    const double labelBlockHeight = 28.0;
    const double minSpacing = labelBlockHeight + 2;

    final sorted = [...labelDataList]
      ..sort((a, b) => a.anchorY.compareTo(b.anchorY));

    // Forward pass: push down
    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final overlap = (prev.anchorY + minSpacing) - curr.anchorY;
      if (overlap > 0) {
        curr.anchorY += overlap;
      }
    }

    // Backward pass: push up
    for (int i = sorted.length - 2; i >= 0; i--) {
      final next = sorted[i + 1];
      final curr = sorted[i];
      final overlap = (curr.anchorY + minSpacing) - next.anchorY;
      if (overlap > 0) {
        curr.anchorY -= overlap;
      }
    }

    // ── 3. Draw ───────────────────────────────────────────────────────────
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final valuePainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final linePaint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final d in labelDataList) {
      final value = data[d.index][valueKey] as double;
      final color = data[d.index][colorKey] as Color;

      // Adjusted end point with corrected Y
      final adjustedEnd = Offset(
        d.end.dx,
        d.anchorY + (d.end.dy - d.mid.dy),
      );

      linePaint.color = color;

      // Leader line: slice edge → elbow
      canvas.drawLine(d.start, Offset(d.mid.dx, d.anchorY), linePaint);

      // Elbow → horizontal tip
      canvas.drawLine(Offset(d.mid.dx, d.anchorY), adjustedEnd, linePaint);

      // Label
      labelPainter.text = TextSpan(
        text: data[d.index][labelKey].toString(),
        style: labelStyle,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          adjustedEnd.dx + (d.rightSide ? 4 : -labelPainter.width - 4),
          adjustedEnd.dy - labelPainter.height - 2,
        ),
      );

      // Value
      valuePainter.text = TextSpan(
        text: value.toInt().toString(),
        style: labelStyle.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
          adjustedEnd.dx + (d.rightSide ? 4 : -valuePainter.width - 4),
          adjustedEnd.dy + 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LabelData {
  final int index;
  final Offset start;
  final Offset mid;
  final Offset end;
  final bool rightSide;
  double anchorY;

  _LabelData({
    required this.index,
    required this.start,
    required this.mid,
    required this.end,
    required this.anchorY,
    required this.rightSide,
  });
}