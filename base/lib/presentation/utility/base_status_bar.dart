
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class BaseStatusBar extends StatelessWidget {
  const BaseStatusBar({
    Key? key,
    this.brightness = Brightness.dark,
    required this.color,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final Brightness brightness;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(

      value: brightness == Brightness.dark
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: color)
          : SystemUiOverlayStyle.light
              .copyWith(statusBarColor: color),
      child: child,
    );
  }
}
