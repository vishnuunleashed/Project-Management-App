
import 'package:flutter/material.dart';

const double _kPanelHeaderCollapsedHeight = kMinInteractiveDimension;
const EdgeInsets _kPanelHeaderExpandedDefaultPadding =
    EdgeInsets.symmetric(vertical: 64.0 - _kPanelHeaderCollapsedHeight);

class BaseExpansionPanelList extends StatelessWidget {
  final void Function(int, bool)? expansionCallback;
  final List<ExpansionPanel> children;
  Color? expandIconColor;
  Color? dividerColor;
  double elevation;
  Key? expandedListKey;
  Duration animationDuration;
  EdgeInsets expandedHeaderPadding;

  BaseExpansionPanelList({
    super.key,
    this.expansionCallback,
    required this.children,
    this.elevation = 2,
    this.expandedListKey,
    this.dividerColor,
    this.expandIconColor,
    this.expandedHeaderPadding = _kPanelHeaderExpandedDefaultPadding,
    this.animationDuration = kThemeAnimationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      animationDuration: animationDuration,
      key: expandedListKey,
      dividerColor: dividerColor,
      elevation: elevation,
      expandedHeaderPadding: expandedHeaderPadding,
      expansionCallback: expansionCallback,
      expandIconColor: expandIconColor,
      children: children,
    );
  }
}