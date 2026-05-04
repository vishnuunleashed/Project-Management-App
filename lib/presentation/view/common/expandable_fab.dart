import 'package:flutter/material.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/utils/routes.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    required this.distance,
    required this.bottomPadding,
  });

  final double distance;
  final double bottomPadding;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const buttonSize = 56.0;
    const actionsCount = 3;

    final maxDistance =
        (screenHeight - (widget.bottomPadding + buttonSize + 40)) / actionsCount;
    final actualDistance =
    widget.distance > maxDistance ? maxDistance : widget.distance;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding, right: 4),
        child: SizedBox(
          width: buttonSize,
          height: actualDistance * (actionsCount + 1) + buttonSize,
          child: Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              _buildExpandingButtons(context, actualDistance, buttonSize),
              _buildMainFab(buttonSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandingButtons(
      BuildContext context, double distance, double size) {
    final icons = [
      Icons.home,
      Icons.settings,
      Icons.person,
    ];

    return BaseStatelessConsumer(
      provider: homeProvider,
      builder: (context, provider, ref) {
        return Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: List.generate(icons.length, (i) {
            return _ExpandingActionButton(
              progress: _expandAnimation,
              offset: distance * (i + 1),
              child: _buildCircleIcon(
                icon: icons[i],
                onPressed: () {
                  // Change routing based on which icon is tapped
                  if (i == 0) {
                    GoRouter.of(context).go(AppRoutes.home);
                  } else if (i == 1) {
                    GoRouter.of(context).go('/home/settings');
                  } else if (i == 2) {
                    GoRouter.of(context).go('/home/profile');
                  }
                  provider.onTabSelected(i);
                  provider.onItemTapped(i);
                },
                size: size,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCircleIcon({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: size * 0.6,
      ),
    );
  }

  Widget _buildMainFab(double size) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 250),
          turns: _open ? 0.125 : 0.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.ads_click,
              color:Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.progress,
    required this.offset,
    required this.child,
  });

  final Animation<double> progress;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return Positioned(
          bottom: progress.value * offset,
          right: 0,
          child: Transform.scale(
            scale: progress.value,
            child: Opacity(
              opacity: progress.value,
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
