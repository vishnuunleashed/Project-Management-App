import 'package:base/presentation/theme_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeProgressWidget extends StatelessWidget {
  final String? remainingTime; // e.g. "22 hrs", "37 min", null if delayed
  final String? delayedTime;   // e.g. "2 hrs ago", "1 days ago"
  final int? daysRemaining;
  final int? totalDays;

  const TimeProgressWidget({
    super.key,
    this.remainingTime,
    this.delayedTime,
    this.daysRemaining,
    this.totalDays
  });

  /// Returns (progress 0..1, label like "22h left" / "37m left").
  (double? progress, String? label) _remainingAsProgress(String? s) {
    if (s == null || s.trim().isEmpty) return (null, null);

    final lower = s.toLowerCase().trim();
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lower);
    if (m == null) return (null, null);

    final value = double.tryParse(m.group(1)!);
    if (value == null) return (null, null);

    double progress;
    String label;
    if (lower.contains('min')) {
      progress = value / 60.0;
      label = '${value.toInt()}m left';
    } else if(lower.contains('day')) {
      // default to hours if "hr/hrs" (or even if unit missing)
      progress = (value / (totalDays ?? 365)).clamp(0.0, 1.0);
      label = '${value.toInt()}d left';
    }
    else{
      progress = (value / 24.0).clamp(0.0, 1.0);
      label = '${value.toInt()}h left';
    }
    // final progress = (hours / 24.0).clamp(0.0, 1.0);
    return (progress, label);
  }



  @override
  Widget build(BuildContext context) {
    final (progress, label) = _remainingAsProgress(remainingTime);
    String result = '';
    if(progress == null ) {
      String raw = delayedTime ?? "0 min ago"; // from JSON
      List<String> parts = raw.split(" ");

      String number = parts[0]; // "29"
      String unit = parts[1][0]; // "m" from "min"

      result = "$number$unit"; // "29m"
    }

    // If we still have remaining time -> show green ring
    if (progress != null) {
      return SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90, // opposite direction (was -90)
                sectionsSpace: 0,
                centerSpaceRadius: 32,
                sections: [
                  PieChartSectionData(
                    value: 1 - progress, // now the grey track comes first
                    color: bayaInfraGrey300,
                    radius: 10,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: progress, // then the green progress fills opposite
                    color: bayaInfraGreen,
                    radius: 10,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            Text(
              label ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: bayaInfraGreen,
              ),
            ),

          ],
        ),
      );
    }else{
      return BlockIcon();
    }
  }
}




class BlockIcon extends StatelessWidget {
  final Color color;
  const BlockIcon({
    super.key,
    this.color = bayaInfraRedColor, // Default: red accent tone
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.4,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.access_time_rounded,
              color: color,
              size: 26,
            ),
          ),
        ),

        Text(
          'Delayed',
          style: TextStyle(
            fontSize: 14,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
