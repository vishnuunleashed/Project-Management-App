// Enums for badge configuration
import 'dart:math';
import 'dart:ui';

import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

enum BadgeSize { compact, standard, large }
enum BadgeVariant { primary, alternative }
enum TransactionStatus { pending, readyToClose, closed , wip}
// Pending Badge Widget with Fixed Animation
class PendingBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const PendingBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _PendingBadgeState createState() => _PendingBadgeState();
}

class _PendingBadgeState extends State<PendingBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon with animated dots
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: PendingIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'PENDING',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }



  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 12.0,
          'paddingV': 6.0,
          'fontSize': 10.0,
          'gap': 6.0,
          'iconSize': 12.0,
          'strokeWidth': 1.2,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 2.5,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF2196F3), Color(0xFF42A5F5)];
      default:
        return [Color(0xFFFF9800), Color(0xFFFFB74D)];
    }
  }
}


class OpenBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const OpenBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _OpenBadge createState() => _OpenBadge();
}

class _OpenBadge extends State<OpenBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon with animated dots
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: PendingIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'OPENED',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }



  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 1.5,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 2.5,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF2196F3), Color(0xFF42A5F5)];
      default:
        return [Color(0xFFFF9800), Color(0xFFFFB74D)];
    }
  }
}



// WIP Badge Widget with Fixed Animation
class WIPBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const WIPBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

  @override
  WIPBadgeState createState() => WIPBadgeState();
}

class WIPBadgeState extends State<WIPBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon with animated dots
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: PendingIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'WIP',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }



  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 1.5,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 2.5,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF2196F3), Color(0xFF42A5F5)];
      default:
        return [Color(0xFFFF9800), Color(0xFFFFB74D)];
    }
  }
}



// No Action Badge Widget with Fixed Animation
class NoActionBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const NoActionBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

  @override
  NoActionBadgeState createState() => NoActionBadgeState();
}

class NoActionBadgeState extends State<NoActionBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon with animated dots
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: CancelIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'NO ACTION',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }



  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 1.5,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 2.5,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [bayaInfraPaleOrange,bayaInfraPaleOrangeRed];
      default:
        return [bayaInfraPaleOrange,bayaInfraPaleOrangeRed];
    }
  }
}



class DelayedBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const DelayedBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

  @override
  DelayedBadgeState createState() => DelayedBadgeState();
}

class DelayedBadgeState extends State<DelayedBadge>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon or animated delay icon
          Icon(
            Icons.access_time_filled,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'DELAYED',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 14.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 12.0,
          'strokeWidth': 1,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 2.5,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [bayaInfraAmber.withValues(alpha: 0.8), bayaInfraAmber];
      default:
        return [bayaInfraPaleOrangeRed.withValues(alpha: 0.8), bayaInfraPaleOrange];
    }
  }
}



// Custom Painter for Pending Icon (Clock with animated dots)
class PendingIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  PendingIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;



    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw clock circle
    canvas.drawCircle(center, radius, paint);

    // Draw clock hands (fixed)
    final handLength = radius * 0.6;
    final minuteHandLength = radius * 0.4;

    // Hour hand (pointing to 12)
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - minuteHandLength),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Minute hand (pointing to 3)
    canvas.drawLine(
      center,
      Offset(center.dx + handLength, center.dy),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth * 0.7
        ..strokeCap = StrokeCap.round,
    );


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}



class CancelIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CancelIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // The X should be smaller and not touch the circle.
    // So we shrink it a bit relative to the radius.
    final gapFactor = 0.35; // smaller value -> closer to circle
    final crossLength = radius * gapFactor;

    // Calculate the coordinates for the two diagonal lines
    final p1 = Offset(center.dx - crossLength, center.dy - crossLength);
    final p2 = Offset(center.dx + crossLength, center.dy + crossLength);
    final p3 = Offset(center.dx - crossLength, center.dy + crossLength);
    final p4 = Offset(center.dx + crossLength, center.dy - crossLength);

    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p3, p4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// Alternative: Hourglass with animated sand
class PendingIconPainter2 extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double animationValue;

  PendingIconPainter2({
    required this.color,
    required this.strokeWidth,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw hourglass outline
    final path = Path();
    final width = size.width * 0.8;
    final height = size.height * 0.8;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;

    // Top part
    path.moveTo(left, top);
    path.lineTo(left + width, top);
    path.lineTo(left + width * 0.8, top + height * 0.4);
    path.lineTo(left + width * 0.5, top + height * 0.5);
    path.lineTo(left + width * 0.2, top + height * 0.4);
    path.close();

    // Bottom part
    final bottomPath = Path();
    bottomPath.moveTo(left + width * 0.5, top + height * 0.5);
    bottomPath.lineTo(left + width * 0.8, top + height * 0.6);
    bottomPath.lineTo(left + width, top + height);
    bottomPath.lineTo(left, top + height);
    bottomPath.lineTo(left + width * 0.2, top + height * 0.6);
    bottomPath.close();

    // Draw outline
    canvas.drawPath(path, paint);
    canvas.drawPath(bottomPath, paint);

    // Animated sand in top part
    final sandHeight = (1 - animationValue) * height * 0.3;
    if (sandHeight > 0) {
      final sandRect = Rect.fromLTWH(
        left + width * 0.25,
        top + height * 0.1,
        width * 0.5,
        sandHeight,
      );
      canvas.drawRect(sandRect, fillPaint);
    }

    // Animated sand in bottom part
    final bottomSandHeight = animationValue * height * 0.3;
    if (bottomSandHeight > 0) {
      final bottomSandRect = Rect.fromLTWH(
        left + width * 0.25,
        top + height * 0.9 - bottomSandHeight,
        width * 0.5,
        bottomSandHeight,
      );
      canvas.drawRect(bottomSandRect, fillPaint);
    }

    // Falling sand particles
    final particleY = top + height * 0.1 + (1 - animationValue) * height * 0.3 +
        animationValue * height * 0.3;
    if (animationValue > 0.1 && animationValue < 0.9) {
      canvas.drawCircle(
        Offset(left + width * 0.5, particleY),
        strokeWidth * 0.5,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Alternative: Pulsing Progress Bars
class PendingIconPainter3 extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double animationValue;

  PendingIconPainter3({
    required this.color,
    required this.strokeWidth,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {


    // Draw 3 horizontal bars with different animation phases
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.2 + (i * size.height * 0.3);
      final animationPhase = (animationValue + i * 0.33) % 1.0;

      // Calculate bar width based on animation
      double barWidth = size.width * 0.8;
      double opacity = (sin(animationPhase * 2 * 3.14159) + 1) / 2;
      opacity = opacity.clamp(0.3, 1.0);

      // Draw background bar
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      // Draw animated progress
      final progressWidth = barWidth * (0.3 + 0.7 * opacity);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.1 + progressWidth, y),
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




// Closed Badge Widget
class ClosedBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const ClosedBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _ClosedBadgeState createState() => _ClosedBadgeState();
}

class _ClosedBadgeState extends State<ClosedBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();
    final isXMark = widget.variant == BadgeVariant.alternative;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: isXMark
                ? XMarkPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            )
                : CheckmarkPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'CLOSED',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 19,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,  // ← Change this from 12.0 to 16.0
          'strokeWidth': 2.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 4.0,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 3.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [bayaInfraPaleOrangeRed, bayaInfraPaleOrange];
      default:
        return [bayaInfraGreen, bayaInfraPaleGreen];
    }
  }
}

// Custom Painters
class SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class XMarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  XMarkPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw X
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Ready To Close Badge Widget
class ReadyToCloseBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const ReadyToCloseBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _ReadyToCloseBadgeState createState() => _ReadyToCloseBadgeState();
}

class _ReadyToCloseBadgeState extends State<ReadyToCloseBadge>
    with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(dimensions['iconSize']!, dimensions['iconSize']!),
            painter: ReadyIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'READY TO CLOSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,

              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 18.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 3.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 2.5,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [Color(0xFFF44336), Color(0xFFEF5350)]; // red gradient (alternative)
      default:
        return [Color(0xFFF44336), Color(0xFFEF5350)]; // red gradient (primary)
    }
  }

}

// Custom Painter for Ready To Close (Pause icon)
class ReadyIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  ReadyIconPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw two vertical bars (pause symbol)
    final barWidth = size.width * 0.2;
    final barHeight = size.height * 0.7;
    final spacing = size.width * 0.2;

    final leftBar = Rect.fromLTWH(
      size.width / 2 - spacing - barWidth / 2,
      size.height / 2 - barHeight / 2,
      barWidth,
      barHeight,
    );

    final rightBar = Rect.fromLTWH(
      size.width / 2 + spacing - barWidth / 2,
      size.height / 2 - barHeight / 2,
      barWidth,
      barHeight,
    );

    canvas.drawRect(leftBar, paint);
    canvas.drawRect(rightBar, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// Closed Badge Widget
class CancelledBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const CancelledBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _CancelledBadgeState createState() => _CancelledBadgeState();
}

class _CancelledBadgeState extends State<CancelledBadge>
    with TickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();


    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close,color: bayaInfraWhiteColor,size: 14,),
          SizedBox(width: 4),
          Text(
            'Cancelled',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 19,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 8.0,
          'iconSize': 16.0,  // ← Change this from 12.0 to 16.0
          'strokeWidth': 2.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 4.0,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 10.0,
          'iconSize': 16.0,
          'strokeWidth': 3.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [bayaInfraPaleOrangeRed, bayaInfraPaleOrange];
      default:
        return [Colors.red, bayaInfraRed];
    }
  }
}

// Rejected Badge Widget
class RejectedBadge extends StatefulWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const RejectedBadge({
    Key? key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  _RejectedBadgeState createState() => _RejectedBadgeState();
}

class _RejectedBadgeState extends State<RejectedBadge>
    with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final dimensions = _getDimensions();
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions['paddingH']!,
        vertical: dimensions['paddingV']!,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block,
            color: bayaInfraWhiteColor,
            size: dimensions['iconSize']!,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'REJECTED',
            style: TextStyle(
              color: Colors.white,
              fontSize: dimensions['fontSize']!,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getDimensions() {
    switch (widget.size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
          'strokeWidth': 2.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
          'strokeWidth': 4.0,
        };
      default: // standard
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 3.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (widget.variant) {
      case BadgeVariant.alternative:
        return [bayaInfraPaleOrangeRed, bayaInfraPaleOrange];
      default:
        return [Colors.red.shade700, bayaInfraRed];
    }
  }
}
