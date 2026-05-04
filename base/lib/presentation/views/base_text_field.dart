import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseTextField<T> extends StatefulWidget {
  const BaseTextField(
      {super.key,
      this.displayTitle = "",
      this.initialValue,
      this.maxLength,
      this.isEnabled = true,
      this.maxLines,
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
      this.isAutoValidateMode = false,
      this.inputDecoration,
      this.contentPadding,
      this.cursorHeight,
      this.customValidator,
      this.textInputAction,
      this.onFieldSubmitted,
      this.readOnly = false});

  final String displayTitle;
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
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isAutoValidateMode;
  final InputDecoration? inputDecoration;
  final double? cursorHeight;
  final String? Function(String?)? customValidator;
  final TextInputAction? textInputAction;
  final bool readOnly;
  @override
  BaseTextFieldState createState() => BaseTextFieldState();
}

class BaseTextFieldState<T> extends State<BaseTextField> {
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
        Visibility(
          visible: widget.displayTitle != "",
          child: Text(widget.displayTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium),
        ),
        Visibility(
            visible: widget.displayTitle != "",
            child: const SizedBox(
              height: 10,
            )),
        TextFormField(
          readOnly: widget.readOnly,
            autovalidateMode: (widget.isAutoValidateMode ?? false)
                ? AutovalidateMode.onUserInteraction
                : null,
            controller: widget.controller,
            keyboardType: widget.textInputType,
            enabled: widget.isEnabled,
            onTap: widget.onTap,
            initialValue: widget.initialValue,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            validator: widget.customValidator ?? validate,
            textAlign: widget.textAlign,
            textInputAction: widget.textInputAction,
            focusNode: widget.focusNode,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: widget.isEnabled
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).disabledColor),
            inputFormatters: [
              if (widget.maxLength != null)
                LengthLimitingTextInputFormatter(widget.maxLength),
              ...?widget.inputFormatters,
            ],
            cursorHeight: widget.cursorHeight,
            decoration: widget.inputDecoration ??
                InputDecoration(
                  alignLabelWithHint: true,
                  label: Text(
                    widget.hintTextNeeded ? widget.hintText ?? "" : '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).disabledColor,

                        ),
                  ),
                  suffixIcon: widget.suffixIcon,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: widget.prefixIcon,
                  contentPadding: widget.contentPadding,
                  filled: widget.fillColorNeeded ?? true,
                  fillColor: widget.fillColor ?? Theme.of(context).cardColor,
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.54,
                        color: Theme.of(context).disabledColor.withOpacity(.5),
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.54,
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 0.54, color: bayaInfraRedColor),
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.54,
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10)),
                  errorBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 0.54, color: bayaInfraRedColor),
                      borderRadius: BorderRadius.circular(10)),
                  counterText: '',
                  // labelStyle: widget.style
                ),
            onSaved: widget.onSaved,
            onChanged: widget.onChanged),
      ],
    );
  }
}
