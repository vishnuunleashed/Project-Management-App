// Assignment Status Badge Widgets

import 'package:flutter/material.dart';

enum BadgeSize { compact, standard, large }
enum BadgeVariant { primary, alternative }

// All Status Badge Widget (Blue - represents overview/all items)
class AllStatusBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const AllStatusBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.grid_view_rounded,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'ALL STATUS',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF1976D2), Color(0xFF2196F3)];
      default:
        return [Color(0xFF0D47A1), Color(0xFF1976D2)];
    }
  }
}

// Assigned Badge Widget (Purple - represents task assignment)
class AssignedBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const AssignedBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.person_add_alt_1,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'ASSIGNED',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF7B1FA2), Color(0xFF9C27B0)];
      default:
        return [Color(0xFF6A1B9A), Color(0xFF8E24AA)];
    }
  }
}

// Assignment Pending Badge Widget (Orange - represents waiting state)
class AssignmentPendingBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const AssignmentPendingBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            painter: PendingIconPainter(
              color: Colors.white,
              strokeWidth: dimensions['strokeWidth']!,
            ),
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'ASSIGNMENT PENDING',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
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
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 2.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFFF57C00), Color(0xFFFF9800)];
      default:
        return [Color(0xFFE65100), Color(0xFFFF6F00)];
    }
  }
}

// Assignment Closed Badge Widget (Green - represents completion)
class AssignmentClosedBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const AssignmentClosedBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            painter: CheckmarkPainter(
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
    switch (size) {
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
          'strokeWidth': 3.5,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
          'strokeWidth': 2.5,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF388E3C), Color(0xFF66BB6A)];
      default:
        return [Color(0xFF2E7D32), Color(0xFF43A047)];
    }
  }
}

// In Progress Badge Widget (Cyan/Teal - represents active work)
class InProgressBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const InProgressBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.play_circle_outline,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'IN PROGRESS',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF00ACC1), Color(0xFF26C6DA)];
      default:
        return [Color(0xFF0097A7), Color(0xFF00BCD4)];
    }
  }
}

// Reviewed Badge Widget (Indigo - represents verification/review)
class ReviewedBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const ReviewedBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.verified_outlined,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'REVIEWED',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF3949AB), Color(0xFF5C6BC0)];
      default:
        return [Color(0xFF283593), Color(0xFF3F51B5)];
    }
  }
}

// Send Back Badge Widget (Amber/Yellow - represents revision needed)
class SendBackBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const SendBackBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.keyboard_return,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'SEND BACK',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFFFFA000), Color(0xFFFFB300)];
      default:
        return [Color(0xFFFF8F00), Color(0xFFFFA726)];
    }
  }
}

// Submitted Badge Widget (Light Green - represents submission)
class SubmittedBadge extends StatelessWidget {
  final BadgeSize size;
  final BadgeVariant variant;

  const SubmittedBadge({
    super.key,
    this.size = BadgeSize.standard,
    this.variant = BadgeVariant.primary,
  });

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
            Icons.upload_file,
            size: dimensions['iconSize']!,
            color: Colors.white,
          ),
          SizedBox(width: dimensions['gap']!),
          Text(
            'SUBMITTED',
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
    switch (size) {
      case BadgeSize.compact:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 12.0,
          'gap': 6.0,
          'iconSize': 14.0,
        };
      case BadgeSize.large:
        return {
          'paddingH': 28.0,
          'paddingV': 16.0,
          'fontSize': 16.0,
          'gap': 12.0,
          'iconSize': 20.0,
        };
      default:
        return {
          'paddingH': 20.0,
          'paddingV': 12.0,
          'fontSize': 14.0,
          'gap': 8.0,
          'iconSize': 16.0,
        };
    }
  }

  List<Color> _getColors() {
    switch (variant) {
      case BadgeVariant.alternative:
        return [Color(0xFF689F38), Color(0xFF8BC34A)];
      default:
        return [Color(0xFF558B2F), Color(0xFF7CB342)];
    }
  }
}

// Custom Painters (reusing from original code)
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

    // Draw clock hands
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
