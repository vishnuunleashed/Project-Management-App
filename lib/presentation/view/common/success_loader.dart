import 'package:base/core/loader_value.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/view/common/error_widget.dart';

import 'animated_loader.dart';

class SuccessLoader<U extends BaseProvider> extends ConsumerStatefulWidget {
  final String transNo;
  final String title;
  // final void Function(String,Map<String,dynamic>) onPressed;
  final void Function() onPressed;
  final U provider;
  final String actionType;
  // final Map<String,dynamic>? extra;
  // final String? routePath;


  const SuccessLoader({
    Key? key,
    this.title = "",
    this.transNo = "",
    required this.onPressed,
    required this.provider,
    required this.actionType,
    // required this.extra,
    // required this.routePath,

  }) : super(key: key);

  @override
  ConsumerState<SuccessLoader<U>> createState() => _SuccessLoaderState();
}

class _SuccessLoaderState<U extends BaseProvider> extends ConsumerState<SuccessLoader<U>>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _iconController;
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _buttonAnimation;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;


  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonAnimation = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonAnimation = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _backgroundController, curve: Curves.easeOut));

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _iconController, curve: Curves.elasticOut));

    _iconRotateAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _iconController, curve: Curves.easeInOut));

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _checkController, curve: Curves.easeInOut));

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _startAnimation();
  }

  void _startAnimation() async {
    // Background fade in
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 100));

    // Icon scale and rotate
    _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 200));

    // Checkmark draw
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    // Checkmark draw
    _buttonAnimation.forward();

    await Future.delayed(const Duration(milliseconds: 200));

    // Text fade in
    _textController.forward();

    // Start pulse animation
    _pulseController.repeat(reverse: true);


  }

  @override
  void dispose() {
    _buttonAnimation.dispose();
    _backgroundController.dispose();
    _iconController.dispose();
    _checkController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    // final ProviderListenable<U> providerOriginal = ProviderListenable<widget.provider>;
    

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _backgroundAnimation,
            _iconScaleAnimation,
            _textAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85 * _backgroundAnimation.value),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: provider.loadingStatus.loader == Loader.loading,
                      child: AnimatedLoaderWidget(
                        size: 80,
                        primaryColor: Colors.green,
                        secondaryColor: Colors.green[700]!,
                      ),
                    ),
                    Visibility(
                        visible: provider.loadingStatus.loader == Loader.error,
                        child: AnimatedErrorWidget(size: 80)),
                    // Main success icon with pulse effect
                    Visibility(
                      visible: provider.loadingStatus.loader == Loader.success,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ScaleTransition(
                          scale: _iconScaleAnimation,
                          child: Transform.rotate(
                            angle: _iconRotateAnimation.value * 0.1,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    bayaInfraGreen,
                                    bayaInfraGreen,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: bayaInfraGreen,
                                //     blurRadius: 20,
                                //     spreadRadius: 0,
                                //     offset: const Offset(0, 8),
                                //   ),
                                // ],
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
                                  // Checkmark
                                  Center(
                                    child: CustomPaint(
                                      painter: CheckmarkPainter(_checkAnimation.value),
                                      size: const Size(60, 60),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 32),
      
                    // Payment successful text
                    FadeTransition(
                      opacity: _textAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_textAnimation),
                        child: Column(
                          children: [
                            Visibility(
                              visible: provider.loadingStatus.loader == Loader.loading,
                              child: Text(
                                'Loading...',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: provider.loadingStatus.loader == Loader.success,
                              child: Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: provider.loadingStatus.loader == Loader.error,
                              child: Center(
                                child: Text(
                                  provider.loadingStatus.exception.toString(),
                                  textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                ),
                              ),
                            ),
      
      
      
                            const SizedBox(height: 8),
      
      
                            // Recipient
                            Text(
                              widget.transNo,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      
      
                    const SizedBox(height: 50),
      
                    // Okay Button
                    Visibility(
                      visible: provider.loadingStatus.loader == Loader.success || provider.loadingStatus.loader == Loader.error,
                      child: FadeTransition(
                        opacity: _buttonAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(_buttonAnimation),
                          child: Center(
                            child: BaseElevatedButton(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              fontSize: 15,
                              borderRadius: 30,
                              width: MediaQuery.of(context).size.width * 0.3,
                              onPressed: (){

                                // widget.onPressed(widget.routePath??"",widget.extra??{});
                                widget.onPressed();
                              },
                              text: 'Ok',
      
                            ),
                          ),
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
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double animationValue;

  CheckmarkPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    final center = Offset(size.width / 2, size.height / 2);
    final startPoint = Offset(center.dx - 12, center.dy + 2);
    final middlePoint = Offset(center.dx - 2, center.dy + 10);
    final endPoint = Offset(center.dx + 14, center.dy - 8);

    if (animationValue > 0) {
      path.moveTo(startPoint.dx, startPoint.dy);

      if (animationValue <= 0.5) {
        final progress = animationValue / 0.5;
        final currentX = startPoint.dx + (middlePoint.dx - startPoint.dx) * progress;
        final currentY = startPoint.dy + (middlePoint.dy - startPoint.dy) * progress;
        path.lineTo(currentX, currentY);
      } else {
        path.lineTo(middlePoint.dx, middlePoint.dy);

        final progress = (animationValue - 0.5) / 0.5;
        final currentX = middlePoint.dx + (endPoint.dx - middlePoint.dx) * progress;
        final currentY = middlePoint.dy + (endPoint.dy - middlePoint.dy) * progress;
        path.lineTo(currentX, currentY);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _controllers[i].forward().then((_) {
            if (mounted) {
              _controllers[i].reverse();
            }
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

