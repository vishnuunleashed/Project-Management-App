
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class BaseElevatedIconButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback? onPressed;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;
  final Widget? iconWidget;
  final double? fontSize;
  const BaseElevatedIconButton({
    Key? key,
    this.icon,
    required this.text,
    this.onPressed,
    this.shape,
    this.padding,
    this.iconWidget,
    this.fontSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: (MediaQuery.of(context).size.width/2.3),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: iconWidget??Icon(icon, size: 16),
        label: Text(text,style:Theme.of(context).textTheme.bodySmall?.copyWith(
            color: bayaInfraWhiteColor,
            fontSize: fontSize??14,
            fontWeight: FontWeight.w600)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: bayaInfraWhiteColor,
          padding: padding??const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
          shape: shape??RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );;
  }
}