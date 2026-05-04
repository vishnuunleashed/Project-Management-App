import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool isCircleEnabled;
  final Color circleColor;
  final double circleWidth;
  final double circleSpacing;
  final String userName;
  final Color? color;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.size = 120,
    this.iconSize,
    this.padding,
    this.circleColor = Colors.blue,
    this.isCircleEnabled = false,
    this.circleWidth = 2.0,
    this.circleSpacing = 1.5,
    required this.userName,
    this.color,
    this.textStyle,
    this.decoration,
  });

  String get _initials {

    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || userName.trim().isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  @override
  Widget build(BuildContext context) {
    // Calculate the extra space needed for circle and spacing
    final double extraSpace = isCircleEnabled ? (circleWidth * 2 + circleSpacing * 2) : 0;

    return Padding(
      padding: padding ?? const EdgeInsets.all(4.0),
      child: Container(
        width: size + extraSpace,
        height: size + extraSpace,
        decoration: isCircleEnabled ? BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: circleColor,
            width: circleWidth,
          ),
        ) : null,
        padding: isCircleEnabled ? EdgeInsets.all(circleSpacing) : null,
        child: ClipOval(
          child: (imageUrl.isEmpty)
              ? _buildPlaceholder(color: color,textStyle: textStyle,decoration:  decoration, context: context)
              : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(color: color,textStyle: textStyle,decoration: decoration,context: context),
            errorWidget: (context, url, error) => _buildPlaceholder(color: color,textStyle: textStyle,decoration: decoration, context: context),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder({Color? color, TextStyle? textStyle,BoxDecoration? decoration, required BuildContext context}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: decoration == null?Theme.of(context).primaryColor:null,

      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        _initials,
        textAlign: TextAlign.center,
        style: textStyle ?? TextStyle(
          color: bayaInfraWhiteColor,
          fontSize: size / 2.5,
          height: 1.0, // <-- removes line height offset
        ),
      ),
    );
  }
}