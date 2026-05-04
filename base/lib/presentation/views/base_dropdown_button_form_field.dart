

import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class BaseDropDownButtonFormField<T> extends StatefulWidget {
  const BaseDropDownButtonFormField(
      {Key? key,
      this.initialValue,
      required this.items,
      this.icon,
      this.iconEnabledColor,
      this.enabledBorder,
      this.focusedBorder,
      this.label = "",
      this.hintText = "",
      this.onSaved,
      this.onChanged,
      this.validator,
      this.onTap,
      required this.builder,
      this.dropdownKey,
      this.padding,
      this.labelColor,
      this.labelFontWeight,
      this.fillColorNeeded,
      this.fillColor,
      this.isExpanded = false})
      : super(key: key);

  final T? initialValue;
  final List<T> items;
  final Icon? icon;
  final Color? iconEnabledColor;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final String label;
  final String hintText;
  final FormFieldSetter<T>? onSaved;
  final FormFieldSetter<T>? onChanged;
  final void Function()? onTap;
  final FormFieldValidator<T>? validator;
  final Widget Function(T) builder;
  final GlobalKey<FormFieldState<String>>? dropdownKey;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final Color? labelColor;
  final FontWeight? labelFontWeight;
  final bool? fillColorNeeded;
  final Color? fillColor;
  @override
  BaseDropDownButtonFormFieldState createState() =>
      BaseDropDownButtonFormFieldState<T>();
}

class BaseDropDownButtonFormFieldState<T>
    extends State<BaseDropDownButtonFormField<T>> {
  T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didUpdateWidget(BaseDropDownButtonFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start ,
        children: [
          Text(widget.label,style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8,),
          DropdownButtonFormField<T>(
              dropdownColor: Theme.of(context).cardColor,
              key: widget.dropdownKey,
              onTap: widget.onTap,
              hint: Text(widget.hintText, style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontWeight: FontWeight.w400,
              ),),
              isExpanded: widget.isExpanded,
              icon: widget.icon ?? const Icon(Icons.keyboard_arrow_down_outlined),
              iconEnabledColor: widget.iconEnabledColor ?? Theme.of(context).disabledColor,
              iconDisabledColor: Theme.of(context).disabledColor.withOpacity(0.5),
              decoration: InputDecoration(
                filled: widget.fillColorNeeded ?? true,
                fillColor: Theme.of(context).colorScheme.secondary,
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),borderRadius:BorderRadius.circular(10)),
                focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).colorScheme.primary),borderRadius: BorderRadius.circular(10)),
                errorBorder:  OutlineInputBorder(borderSide: const BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius: BorderRadius.circular(10)),
                focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width:  widget.onChanged == null?1:0.54,color: widget.onChanged == null ? Theme.of(context).disabledColor.withValues(alpha: 0.5) : Theme.of(context).colorScheme.primary),borderRadius: BorderRadius.circular(10)),
              ),
              value: widget.items.contains(_value) ? _value : null,
              items: widget.items
                  .map((value) => DropdownMenuItem<T>(
                  value: value, child: widget.builder(value)))
                  .toList(),
              selectedItemBuilder: (BuildContext context) {
                return widget.items.map((value) {
                  return DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: widget.onChanged!=null?Theme.of(context).textTheme.bodyLarge?.color:Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                    child: widget.builder(value),
                  );
                }).toList();
              },
              onChanged: widget.onChanged,
              onSaved: widget.onSaved,
              validator: widget.validator),
        ],
      ),
    );
  }
}
