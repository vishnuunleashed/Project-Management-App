import 'package:flutter/material.dart';

class AnimatedErrorWidget extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedErrorWidget({
    Key? key,
    this.size = 100.0,
    this.primaryColor = const Color(0xFFE53E3E),
    this.secondaryColor = const Color(0xFFD32F2F)
  }) : super(key: key);

  @override
  State<AnimatedErrorWidget> createState() => _AnimatedErrorWidgetState();
}

class _AnimatedErrorWidgetState extends State<AnimatedErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _iconController;
  late AnimationController _rotationController;
  late AnimationController _crossController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;
  late Animation<double> _crossAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _crossController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _iconController, curve: Curves.elasticOut));

    _iconRotateAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));

    _crossAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _crossController, curve: Curves.easeInOut));

    // Start animations
    _startAnimation();
  }

  void _startAnimation() async {
    _iconController.forward();
    _rotationController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _crossController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconController.dispose();
    _rotationController.dispose();
    _crossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _iconScaleAnimation, _iconRotateAnimation, _crossAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: ScaleTransition(
            scale: _iconScaleAnimation,
            child: Transform.rotate(
              angle: _iconRotateAnimation.value * 0.1,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.primaryColor, // Error Red
                      widget.secondaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background circle with subtle gradient
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Error Cross
                    Center(
                      child: CustomPaint(
                        painter: ErrorCrossPainter(_crossAnimation.value),
                        size: Size(widget.size * 0.6, widget.size * 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ErrorCrossPainter extends CustomPainter {
  final double animationValue;

  ErrorCrossPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // First line (top-left to bottom-right)
    final line1Start = Offset(center.dx - radius, center.dy - radius);
    final line1End = Offset(center.dx + radius, center.dy + radius);

    // Second line (top-right to bottom-left)
    final line2Start = Offset(center.dx + radius, center.dy - radius);
    final line2End = Offset(center.dx - radius, center.dy + radius);

    if (animationValue > 0) {
      // Draw first line
      if (animationValue <= 0.5) {
        final progress = animationValue / 0.5;
        final currentEnd = Offset(
          line1Start.dx + (line1End.dx - line1Start.dx) * progress,
          line1Start.dy + (line1End.dy - line1Start.dy) * progress,
        );
        canvas.drawLine(line1Start, currentEnd, paint);
      } else {
        // Draw complete first line
        canvas.drawLine(line1Start, line1End, paint);

        // Draw second line
        final progress = (animationValue - 0.5) / 0.5;
        final currentEnd = Offset(
          line2Start.dx + (line2End.dx - line2Start.dx) * progress,
          line2Start.dy + (line2End.dy - line2Start.dy) * progress,
        );
        canvas.drawLine(line2Start, currentEnd, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
