

import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseNumberField<T> extends StatefulWidget {
  const BaseNumberField(
      {Key? key,
        required this.displayTitle,
        this.initialValue,
        this.style,
        this.maxLength,
        this.isEnabled = true,
        this.maxLines = 1,
        this.onChanged,
        this.onSaved,
        this.validator,
        this.controller,
        this.focusNode,
        this.inputFormatters,
        this.fillColorNeeded,
        this.fillColor,
        this.onTap,
        this.hintTextNeeded = false,
        this.hintText,
      })
      : super(key: key);

  final String displayTitle;
  final String? initialValue;
  final TextStyle? style;
  final int? maxLength;
  final bool? isEnabled;
  final ValueSetter<String>? onChanged;
  final void Function()? onTap;
  final ValueSetter<String?>? onSaved;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool? fillColorNeeded;
  final Color? fillColor;
  final bool hintTextNeeded;
  final String? hintText;

  @override
  BaseNumberFieldState createState() => BaseNumberFieldState();
}

class BaseNumberFieldState<T> extends State<BaseNumberField> {
  String? initialValue;

  @override
  void initState() {
    super.initState();
    initialValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.displayTitle,style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: bayaInfraGreyColor,
          )),
          const SizedBox(height: 8.0),
          TextFormField(
            enableInteractiveSelection: false,
            onTap: widget.onTap,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            controller: widget.controller,
            enabled: widget.isEnabled,
            initialValue: initialValue,
            style: widget.style??Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: (widget.isEnabled??true)?Theme.of(context).textTheme.bodyLarge?.color:Theme.of(context).disabledColor.withValues(alpha: 0.5)
            ),
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
                alignLabelWithHint: true,
                filled: widget.fillColorNeeded??true,
                fillColor: Theme.of(context).colorScheme.secondary,
                label: Text(widget.hintTextNeeded?widget.hintText??"":'', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5)
                )),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1,color: Theme.of(context).disabledColor.withOpacity(.5),),borderRadius:BorderRadius.circular(10)),
                focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
                focusedErrorBorder:  OutlineInputBorder(borderSide: const BorderSide(width: 1,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
                enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
                errorBorder:  OutlineInputBorder(borderSide: const BorderSide(width: 1,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
                counterText: '',
                labelStyle: widget.style),
            onSaved: widget.onSaved,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
