import 'package:flutter/material.dart';

class WaveBlender extends StatelessWidget {
  final double height;
  final Color color;

  const WaveBlender({
    super.key,
    this.height = 60,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: WavePainter(color: color),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw three overlapping waves with increasing opacity to create a blended transition.
    final Paint paint1 = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint paint2 = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final Paint paint3 = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // First (tallest, most transparent) wave
    Path path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.5);
    path1.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.2);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second (middle) wave
    Path path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
        size.width * 0.2, size.height * 0.3, size.width * 0.5, size.height * 0.65);
    path2.quadraticBezierTo(
        size.width * 0.8, size.height * 1.0, size.width, size.height * 0.4);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Third (solid, bottom) wave
    Path path3 = Path();
    path3.moveTo(0, size.height * 0.8);
    path3.quadraticBezierTo(
        size.width * 0.25, size.height * 0.6, size.width * 0.6, size.height * 0.85);
    path3.quadraticBezierTo(
        size.width * 0.85, size.height * 1.0, size.width, size.height * 0.7);
    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
