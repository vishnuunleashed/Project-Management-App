
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:flutter/material.dart';

class BaseSnackBar {
  static final BaseSnackBar _instance = BaseSnackBar._();
  BaseSnackBar._();
  factory BaseSnackBar() {
    return _instance;
  }
  final ScaffoldMessengerState _state =
      ScaffoldMessenger.of(NavigatorKey.navKey.currentState!.context);
  final BuildContext _context = NavigatorKey.navKey.currentState!.context;

  void show({String message = "Test",Color? textColor}) {
    hide();

    _state.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
            .textTheme
            .bodyLarge
            ?.color,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 10,
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            message,
            style: Theme.of(NavigatorKey.navKey.currentState!.context)
                .textTheme
                .titleLarge
                ?.copyWith(
                fontWeight: FontWeight.w500,
                    color: Theme.of(NavigatorKey.navKey.currentState!.context)
                        .scaffoldBackgroundColor),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void hide() => _state.hideCurrentSnackBar();
}
