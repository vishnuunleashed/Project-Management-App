
import 'package:flutter/material.dart';

class BaseExpansionTile extends StatelessWidget {
  final Key? expTileKey;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final ValueChanged<bool>? onExpansionChanged;
  final Color? backgroundColor;
  final Widget? trailing;
  final Color? collapsedBackgroundColor;
  final bool initiallyExpanded;
  final bool maintainState;
  final EdgeInsetsGeometry? tilePadding;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final Alignment? expandedAlignment;
  final EdgeInsetsGeometry? childrenPadding;
  final Color? textColor;
  final Color? collapsedTextColor;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;
  final Clip? clipBehavior;
  final ListTileControlAffinity? controlAffinity;
  final ExpansionTileController? controller;
  final List<Widget> children;

  const BaseExpansionTile({
    super.key,
    this.expTileKey,
    this.leading,
    required this.title,
    this.subtitle,
    this.onExpansionChanged,
    this.backgroundColor,
    this.trailing,
    this.collapsedBackgroundColor,
    this.initiallyExpanded = false,
    this.maintainState = false,
    this.tilePadding,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.textColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.shape,
    this.collapsedShape,
    this.clipBehavior,
    this.controlAffinity,
    this.controller,
    this.children = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExpansionTile(
        key: expTileKey,
        leading: leading,
        title: title,
        subtitle: subtitle,
        onExpansionChanged: onExpansionChanged,
        backgroundColor: backgroundColor,
        trailing: trailing,
        collapsedBackgroundColor: collapsedBackgroundColor,
        initiallyExpanded: initiallyExpanded,
        maintainState: maintainState,
        tilePadding: tilePadding,
        expandedCrossAxisAlignment: expandedCrossAxisAlignment,
        expandedAlignment: expandedAlignment,
        childrenPadding: childrenPadding,
        textColor: textColor,
        collapsedTextColor: collapsedTextColor,
        iconColor: iconColor,
        collapsedIconColor: collapsedIconColor,
        shape: shape,
        collapsedShape: collapsedShape,
        clipBehavior: clipBehavior,
        controlAffinity: controlAffinity,
        controller: controller,
        children: children,
    );
  }
}
