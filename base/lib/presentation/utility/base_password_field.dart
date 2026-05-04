

import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasePasswordField<T> extends StatefulWidget {
  const BasePasswordField({
    Key? key,
    this.displayTitle,
    this.initialValue,
    this.maxLength,
    this.isEnabled = true,
    this.maxLines = 1,
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
    this.prefixIcon,
    this.hintTextNeeded = false,
    this.hintText,
    this.inputFormatters,
    this.focusNode,
    this.paddingBtwTtlInp
  }) : super(key: key);

  final String? displayTitle;
  final String? initialValue;
  final int? maxLength;
  final bool isEnabled;
  final ValueSetter<String>? onChanged;
  final ValueSetter<String?>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextStyle? style;
  final int maxLines;
  final Color? fillColor;
  final bool? fillColorNeeded;
  final InputBorder? enabledBorder;
  final InputBorder? focusBorder;
  final TextInputType? textInputType;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final bool hintTextNeeded;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final double? paddingBtwTtlInp;

  @override
  BasePasswordFieldState createState() => BasePasswordFieldState();
}

class BasePasswordFieldState<T> extends State<BasePasswordField> {
  String? initialValue;
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
    initialValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.displayTitle??"Password",style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500
    )),
         SizedBox(height: widget.paddingBtwTtlInp ?? 10,),
        TextFormField(

          focusNode: widget.focusNode,
            obscureText: _obscureText,
            controller: widget.controller,
            keyboardType: widget.textInputType,
            enabled: widget.isEnabled,
            initialValue: widget.initialValue,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters?? [FilteringTextInputFormatter.deny(RegExp(r'\n')),],
            validator: widget.validator,
            textAlign: widget.textAlign,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: widget.isEnabled?Theme.of(context).textTheme.titleMedium?.color:Theme.of(context).disabledColor.withValues(alpha: 0.5)
            ),
            decoration: InputDecoration(
                alignLabelWithHint: true,
                label: Text(widget.hintTextNeeded?widget.hintText??"":'',style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).disabledColor
                )),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).disabledColor.withOpacity(.5),),borderRadius:BorderRadius.circular(10)),
                focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
                focusedErrorBorder:  OutlineInputBorder(borderSide: const BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
                enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 0.54,color: Theme.of(context).colorScheme.primary),borderRadius:BorderRadius.circular(10)),
                errorBorder:  OutlineInputBorder(borderSide: const BorderSide(width: 0.54,color: bayaInfraRedColor),borderRadius:BorderRadius.circular(10)),
                prefixIcon: widget.prefixIcon,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: widget.fillColorNeeded??true,
                fillColor: Theme.of(context).colorScheme.secondary,
                counterText:
                '', //To remove character counter (e.g., "4/50") that is displayed, while setting the maxLength
                labelStyle: widget.style,
                suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).iconTheme.color,)
                )),
            onSaved: widget.onSaved,
            onChanged: widget.onChanged),
      ],
    );
  }
}



