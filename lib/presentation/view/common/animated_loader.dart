import 'package:flutter/material.dart';

class AnimatedLoaderWidget extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedLoaderWidget({
    super.key,
    this.size = 100.0,
    this.primaryColor = const Color(0xFF4285F4),
    this.secondaryColor = const Color(0xFF1976D2),
  });

  @override
  State<AnimatedLoaderWidget> createState() => _AnimatedLoaderWidgetState();
}

class _AnimatedLoaderWidgetState extends State<AnimatedLoaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _iconController;
  late AnimationController _rotationController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;

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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _iconController, curve: Curves.elasticOut));

    _iconRotateAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut));

    // Start animations
    _iconController.forward();
    _rotationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _iconScaleAnimation, _iconRotateAnimation]),
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
                      widget.primaryColor, // Google Blue
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
                    // Loading Spinner
                    Center(
                      child: SizedBox(
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
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

// Usage Examples
class LoaderDemo extends StatelessWidget {
  const LoaderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Default Google Pay style
            AnimatedLoaderWidget(),

            const SizedBox(height: 40),

            // Custom size and colors
            AnimatedLoaderWidget(
              size: 80,
              primaryColor: Colors.green,
              secondaryColor: Colors.green[700]!,
            ),

            const SizedBox(height: 40),

            // Different color scheme
            AnimatedLoaderWidget(
              size: 120,
              primaryColor: Colors.purple,
              secondaryColor: Colors.purple[800]!,
            ),
          ],
        ),
      ),
    );
  }
}