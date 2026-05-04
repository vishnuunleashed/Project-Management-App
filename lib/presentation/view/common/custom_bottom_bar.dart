import 'package:flutter/material.dart';

enum Status { pending, readyToClose, closed }

enum ServiceStatus { all, pending,closed,cancelled }

enum CreatedObservationStatus { pending,submit, closed}

enum AllObservationAndSupportStatus { opened, delayed, closed }
enum ServiceSupportSiteWiseStatus {all, pending, closed , cancelled}



enum AllObservationAndSupportStatusUserWise { opened, closed }




class EnumBottomBar<T> extends StatefulWidget {
  final List<T> items; // enum values
  final List<String> titles;
  final List<IconData> icons;
  final ValueChanged<T> onTabSelected;
  final int initialIndex;

  const EnumBottomBar({
    super.key,
    required this.items,
    required this.titles,
    required this.icons,
    required this.onTabSelected,
    this.initialIndex = 0,
  }) : assert(items.length == titles.length && titles.length == icons.length,
  "items, titles, and icons must have the same length");

  @override
  State<EnumBottomBar<T>> createState() => _EnumBottomBarState<T>();
}

class _EnumBottomBarState<T> extends State<EnumBottomBar<T>> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant EnumBottomBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(widget.titles.length, (index) {
            final bool isSelected = _selectedIndex == index;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onTabSelected(widget.items[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.titles[index] == "No Action" ?
                        NoActionIcon(
                          size: 25,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodySmall?.color ?? Colors.redAccent,
                          strokeWidth: 2.5,
                        ):

                        Icon(
                          widget.icons[index],
                          size: 28,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.titles[index],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodySmall?.color,

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


/// A standalone No Action icon (circle with X mark)
class NoActionIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const NoActionIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _NoActionIconPainter(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Painter that draws a circular border with an X inside (No Action)
class _NoActionIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _NoActionIconPainter({
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

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw smaller X inside
    final gapFactor = 0.35;
    final crossLength = radius * gapFactor;

    final p1 = Offset(center.dx - crossLength, center.dy - crossLength);
    final p2 = Offset(center.dx + crossLength, center.dy + crossLength);
    final p3 = Offset(center.dx - crossLength, center.dy + crossLength);
    final p4 = Offset(center.dx + crossLength, center.dy - crossLength);

    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p3, p4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
