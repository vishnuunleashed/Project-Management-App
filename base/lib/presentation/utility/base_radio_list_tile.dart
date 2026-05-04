
import 'package:flutter/material.dart';

class BaseRadioListTile extends StatelessWidget {
  final Widget? title;
  final Color? hoverColor;
  final Color? tileColor;
  final Color? activeColor;
  final dynamic groupValue;
  final dynamic value;
  final void Function(dynamic)? onChanged;

  const BaseRadioListTile({
    super.key,
    this.title,
    this.hoverColor,
    this.tileColor,
    this.activeColor,
    this.groupValue,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
// TODO: implement build
    return RadioListTile(
      title: title,
      hoverColor: hoverColor,
      tileColor: tileColor,
      activeColor: activeColor,
      groupValue: groupValue,
      value: value,
      onChanged: onChanged,
    );
  }
}
