
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/orientation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseTopSheet {
  static void show({
    required BuildContext context,
    String? title,
    required Widget child,
    Widget? actionIcon,
    Function()? actionOnPressed,
    required Widget bottomButton,
    bool? barrierDismissible

  }) {
    bool isDarkMode = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = NavigatorKey.navKey.currentState?.context;
      if (context != null) {
        isDarkMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark;
      }
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: (barrierDismissible) ?? true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24.0, left: 24.0),
                            child: Text(
                              title ?? "Filter",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, right: 24.0),
                          child: IconButton(
                            icon: actionIcon ??
                                Icon(
                                  Icons.close,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32,
                                ),
                            onPressed: () {
                              actionOnPressed != null
                                  ? actionOnPressed!()
                                  : GoRouter.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Divider(color: Colors.grey, height: 1, thickness: 1),
                    ),

                    Flexible(child: child),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [Expanded(child: bottomButton)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: child,
        );
      },
    );

  }
}
