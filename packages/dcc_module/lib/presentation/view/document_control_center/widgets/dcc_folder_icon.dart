import 'package:flutter/material.dart';

class DccFolderIcon extends StatelessWidget {
  final Color bodyColor;
  final Color tabColor;
  final double size;

  const DccFolderIcon({
    super.key,
    required this.bodyColor,
    required this.tabColor,
    this.size = 38.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: _FolderPainter(
        bodyColor: bodyColor,
        tabColor: tabColor,
      ),
    );
  }
}

class _FolderPainter extends CustomPainter {
  final Color bodyColor;
  final Color tabColor;

  _FolderPainter({required this.bodyColor, required this.tabColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final tabPaint = Paint()
      ..color = tabColor
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double radius = width * 0.1;
    final double tabWidth = width * 0.45;
    final double tabHeight = height * 0.2;

    // Draw Tab (The top part)
    final RRect tabRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, tabWidth, tabHeight * 2),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
    canvas.drawRRect(tabRect, tabPaint);

    // Draw Body (The main part)
    final RRect bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, tabHeight, width, height - tabHeight),
      topLeft: Radius.zero,
      topRight: Radius.circular(radius * 1.5),
      bottomLeft: Radius.circular(radius * 1.5),
      bottomRight: Radius.circular(radius * 1.5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    
    // Optional: Add a subtle highlight or shadow to the tab edge
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(bodyRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
