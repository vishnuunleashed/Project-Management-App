
import 'package:flutter/material.dart';

class BaseElevatedButtonSecondary extends StatelessWidget {
  const BaseElevatedButtonSecondary(
      {Key? key,
        required this.child,
        required this.onPressed,
        this.borderColor,
        this.enabled = true,
        this.textColor})
      : super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final Color? borderColor;
  final bool enabled;
  final Color? textColor;

  void baseOnPressed(BuildContext context) {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();
    // Call the provided onPressed callback
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: BorderSide(color: borderColor ??Theme.of(context).primaryColor),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            onPressed: enabled ? () => baseOnPressed(context) : null,
            child: DefaultTextStyle(
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: textColor??Theme.of(context).primaryColor,),
                child: child)));
  }
}
