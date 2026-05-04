import 'package:flutter/material.dart';

class BaseDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? subtitle;
  final Widget? icon;
  final List<Widget> actions;
  final Color? backgroundColor;
  final String? transNo;
  final bool barrierDismissible;

  const BaseDialog({
    Key? key,
    required this.message,
    required this.title,
    this.subtitle,
    this.icon,
    required this.actions,
    this.backgroundColor,
    this.transNo,
    this.barrierDismissible = true
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? subtitle,
    Widget? icon,
    String? transNo,
    required List<Widget> actions,
    Color? backgroundColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (ctx) => BaseDialog(
        title: title,
        message: message,
        subtitle: subtitle,
        transNo: transNo,
        icon: icon,
        actions: actions,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.6;

    return AlertDialog(
      backgroundColor:
      backgroundColor ?? Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      title: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (icon != null) ...[
                icon!,
                const SizedBox(height: 8),

              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              (transNo != null) ?
                  Text(transNo ?? "" ,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),) :
                  Container()
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }

}
