import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/orientation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HorizontalBarRodType { opened, delayed }

class HorizontalBarChart extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> data;
  final String labelKey;
  final String valueKey;
  final String colorKey;
  final String? secondValueKey;
  final String? secondColorKey;
  final String? firstLegendLabel;
  final String? secondLegendLabel;
  final double barWidth;
  final double? separationHeight;

  /// Generic fallback — used when neither specific callback is provided.
  final Function(Map<String, dynamic> data, int index)? onBarTap;

  /// Called only when the "opened / on-track" rod is tapped.
  /// If null and [onBarTap] is set, [onBarTap] is used as fallback.
  final Function(Map<String, dynamic> data, int index)? onOpenTap;

  /// Called only when the "delayed" rod is tapped.
  /// If null and [onBarTap] is set, [onBarTap] is used as fallback.
  final Function(Map<String, dynamic> data, int index)? onDelayTap;

  const HorizontalBarChart({
    super.key,
    required this.data,
    this.labelKey = 'label',
    this.valueKey = 'value',
    this.colorKey = 'color',
    this.secondValueKey,
    this.secondColorKey,
    this.firstLegendLabel,
    this.secondLegendLabel,
    this.barWidth = 8,
    this.onBarTap,
    this.onOpenTap,
    this.onDelayTap,
    this.separationHeight,
  });

  @override
  ConsumerState<HorizontalBarChart> createState() => _HorizontalBarChartState();
}

class _HorizontalBarChartState extends ConsumerState<HorizontalBarChart> {
  int? touchedGroupIndex;
  int? touchedRodIndex;

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  HorizontalBarRodType? _rodTypeForIndex(int groupIndex, int rodIndex) {
    final List<HorizontalBarRodType> present = [];

    final double value1 =
    (widget.data[groupIndex][widget.valueKey] ?? 0).toDouble();
    final double value2 = widget.secondValueKey != null
        ? (widget.data[groupIndex][widget.secondValueKey!] ?? 0).toDouble()
        : 0;

    if (value1 > 0) present.add(HorizontalBarRodType.opened);
    if (widget.secondValueKey != null && value2 > 0) {
      present.add(HorizontalBarRodType.delayed);
    }

    if (rodIndex < present.length) return present[rodIndex];
    return null;
  }

  /// Resolves which callback to fire:
  /// - opened rod → onOpenTap if provided, else onBarTap fallback
  /// - delayed rod → onDelayTap if provided, else onBarTap fallback
  /// - neither exists → do nothing
  void _handleTap(int groupIndex, int rodIndex) {
    final rodType = _rodTypeForIndex(groupIndex, rodIndex);
    if (rodType == null) return;
    if (groupIndex < 0 || groupIndex >= widget.data.length) return;

    final data = widget.data[groupIndex];

    if (rodType == HorizontalBarRodType.opened) {
      if (widget.onOpenTap != null) {
        widget.onOpenTap!(data, groupIndex);
      } else {
        widget.onBarTap?.call(data, groupIndex,);
      }
    } else {
      if (widget.onDelayTap != null) {
        widget.onDelayTap!(data, groupIndex);
      } else {
        widget.onBarTap?.call(data, groupIndex,);
      }
    }
  }

  double getMaxY() {
    final groups = getBarChartGroups();
    final rawMax = groups
        .expand((g) => g.barRods.map((r) => r.toY))
        .fold<double>(0, (p, e) => e > p ? e : p);
    final maxValue = (rawMax.isFinite && rawMax > 0 ? rawMax : 1);
    return maxValue + maxValue / 5;
  }

  List<BarChartGroupData> getBarChartGroups() {
    return List.generate(widget.data.length, (i) {
      final double value1 = (widget.data[i][widget.valueKey] ?? 0).toDouble();
      final double value2 = widget.secondValueKey != null
          ? (widget.data[i][widget.secondValueKey!] ?? 0).toDouble()
          : 0;

      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          if (value1 > 0)
            BarChartRodData(
              toY: value1,
              color: widget.data[i][widget.colorKey],
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
          if (widget.secondValueKey != null && value2 > 0)
            BarChartRodData(
              toY: value2,
              color: widget.data[i][widget.secondColorKey!] ?? Colors.grey,
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) return const SizedBox.shrink();

    final maxY = getMaxY();
    final groups = getBarChartGroups();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 0.5,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(width: 0.5, color: theme.cardColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, top: 4.0),
                child: Text(
                  widget.data.first['title'] ?? "",
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: widget.separationHeight ?? widget.data.length * 60,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      minY: 0,
                      alignment: BarChartAlignment.spaceEvenly,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= widget.data.length) {
                                return const SizedBox.shrink();
                              }
                              return Center(
                                child: SizedBox(
                                  height: 50,
                                  width: 55,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top: -299,
                                        right: 0,
                                        bottom: 18,
                                        left: 0,
                                        child: RotatedBox(
                                          quarterTurns: -1,
                                          child: Text(
                                            textAlign: TextAlign.start,
                                            widget.data[index][widget.labelKey]
                                                .toString(),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(fontSize: 11),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0) return const SizedBox();
                              return Transform.rotate(
                                angle: -1.5708,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  value == meta.max
                                      ? ''
                                      : value.toInt().toString(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) {
                            if (touchedRodIndex != null &&
                                touchedRodIndex! < group.barRods.length) {
                              return group.barRods[touchedRodIndex!].color ??
                                  Colors.black87;
                            }
                            return Colors.black87;
                          },
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final value = _formatNumber(rod.toY);
                            final rodType =
                            _rodTypeForIndex(groupIndex, rodIndex);
                            String prefix = "";
                            if (widget.secondValueKey != null &&
                                rodType != null) {
                              prefix = rodType == HorizontalBarRodType.opened
                                  ? "${widget.firstLegendLabel ?? 'Opened'}: "
                                  : "${widget.secondLegendLabel ?? 'Delayed'}: ";
                            }
                            return BarTooltipItem(
                              "$prefix$value",
                              theme.textTheme.labelLarge!
                                  .copyWith(color: Colors.white),
                            );
                          },
                        ),
                        touchCallback:
                            (FlTouchEvent event, BarTouchResponse? response) {
                          setState(() {
                            if (response != null &&
                                response.spot != null &&
                                event is! FlPanEndEvent &&
                                event is! FlPointerExitEvent) {
                              touchedGroupIndex =
                                  response.spot!.touchedBarGroupIndex;
                              touchedRodIndex =
                                  response.spot!.touchedRodDataIndex;
                            } else {
                              touchedGroupIndex = null;
                              touchedRodIndex = null;
                            }
                          });

                          if (event is FlTapUpEvent && response?.spot != null) {
                            _handleTap(
                              response!.spot!.touchedBarGroupIndex,
                              response.spot!.touchedRodDataIndex,
                            );
                          }
                        },
                      ),
                      barGroups: groups,
                    ),
                  ),
                ),
              ),
              if (widget.secondValueKey != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        context,
                        widget.firstLegendLabel ?? "Opened",
                        widget.data.first[widget.colorKey],
                      ),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        context,
                        widget.secondLegendLabel ?? "Delayed",
                        widget.data.first[widget.secondColorKey!],
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

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}