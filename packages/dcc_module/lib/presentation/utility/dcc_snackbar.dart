import 'package:flutter/material.dart';

class DccSnackBar {
  static final DccSnackBar _instance = DccSnackBar._();
  DccSnackBar._();
  factory DccSnackBar() {
    return _instance;
  }

  void show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
  }) {
    final state = ScaffoldMessenger.of(context);
    state.hideCurrentSnackBar();

    final theme = Theme.of(context);

    state.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor ?? theme.textTheme.bodyLarge?.color ?? const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            message,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.scaffoldBackgroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void hide(BuildContext context) => ScaffoldMessenger.of(context).hideCurrentSnackBar();
}
