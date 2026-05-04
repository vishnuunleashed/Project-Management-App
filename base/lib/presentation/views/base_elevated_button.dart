
import 'package:flutter/material.dart';

class BaseElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color borderColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double elevation;
  final double? borderWidth;
  final WidgetStateProperty<Color?>? splashColor;

  const BaseElevatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.elevation = 0,
    this.borderWidth,
    this.splashColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(

        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          elevation: elevation,
          padding: padding ?? (height == null ? const EdgeInsets.symmetric(vertical: 12) : null),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor,width:borderWidth ?? 0.3),
          ),
        ).copyWith(
        overlayColor: splashColor, // 🔥 splash color
      ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}