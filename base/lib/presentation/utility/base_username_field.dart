
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseUserNameField<T> extends StatefulWidget {
  const BaseUserNameField({
    super.key,
    this.displayTitle,
    this.initialValue,
    this.maxLength,
    this.isEnabled = true,
    this.maxLines ,
    this.onChanged,
    this.onSaved,
    this.fillColor,
    this.fillColorNeeded,
    this.enabledBorder,
    this.focusBorder,
    this.validator,
    this.style,
    this.textInputType,
    this.controller,
    this.textAlign = TextAlign.start,
    this.isRequiredField = false,
    this.customValidationMessage,
    this.onTap,
    this.suffixIcon,
    this.hintTextNeeded = false,
    this.prefixIcon,
    this.hintText,
    this.focusNode,
    this.inputFormatters,
  });

  final String? displayTitle;
  final String? hintText;
  final String? initialValue;
  final int? maxLength;
  final bool isEnabled;
  final ValueSetter<String>? onChanged;
  final ValueSetter<String?>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextStyle? style;
  final int? maxLines;
  final Color? fillColor;
  final bool? fillColorNeeded;
  final bool hintTextNeeded;
  final InputBorder? enabledBorder;
  final InputBorder? focusBorder;
  final TextInputType? textInputType;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final bool isRequiredField;
  final String? customValidationMessage;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  @override
  BaseUserNameFieldState createState() => BaseUserNameFieldState();
}

class BaseUserNameFieldState<T> extends State<BaseUserNameField> {
  String? initialValue;
  @override
  void initState() {
    super.initState();
    initialValue = widget.initialValue;
  }
  String? validate(String? value) {
    if (widget.isRequiredField && (value == null || value.isEmpty)) {
      return widget.customValidationMessage == null ||
          widget.customValidationMessage!.isEmpty
          ? 'Please enter a value'
          : widget.customValidationMessage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.displayTitle??"Username",style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500
        )),
        const SizedBox(height: 10,),
        TextFormField(

            controller: widget.controller,
            keyboardType: widget.textInputType,
            enabled: widget.isEnabled,
            onTap: widget.onTap,
            initialValue: widget.initialValue,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            validator: validate,
            textAlign: widget.textAlign,
            focusNode: widget.focusNode,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: widget.isEnabled?Theme.of(context).textTheme.titleMedium?.color:Theme.of(context).disabledColor
            ),
            inputFormatters: widget.inputFormatters??[FilteringTextInputFormatter.deny(RegExp(r'\n')),],
            decoration: InputDecoration(
              alignLabelWithHint: true,
              label: Text(widget.hintTextNeeded?widget.hintText??"":'',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              suffixIcon: widget.suffixIcon,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              prefixIcon: widget.prefixIcon,
              filled: widget.fillColorNeeded??true,
              fillColor: Theme.of(context).colorScheme.secondary,
              disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).disabledColor.withOpacity(.5),),borderRadius:BorderRadius.circular(10)),
              focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
              focusedErrorBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
              enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
              errorBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
              counterText: '',
              // labelStyle: widget.style
            ),
            onSaved: widget.onSaved,
            onChanged: widget.onChanged),
      ],
    );
  }
}
