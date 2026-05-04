
import 'dart:io';

import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/provider/settings/settings_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';



class BaseBottomSheet {
  static void show({
    required BuildContext context,
    required Widget child,
    bool? barrierDismissible,
    bool? enableDrag,
    double? height,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    BorderRadius borderRadius =
    const BorderRadius.vertical(top: Radius.circular(20)),
    Color? backgroundColor,
    bool showSlideLine = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      enableDrag: enableDrag ?? true,
      isDismissible: barrierDismissible ?? true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) {
        return BaseConsumer<SettingsProvider>(
          provider: settingsProvider,
          builder: (context, _,ref) {
            final ThemeMode currentTheme = ref.watch(
              settingsProvider.select((settings) => settings.currentTheme),
            );

            final isDarkTheme =
                (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark &&
                    currentTheme == ThemeMode.system) ||
                    currentTheme == ThemeMode.dark;

            final theme = Theme.of(context);
            final viewInsets = MediaQuery.of(context).viewInsets;

            final isIOS = Platform.isIOS;

            final content = AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              curve: Curves.easeOut,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? bayaInfraLightCardColorDark
                      : theme.scaffoldBackgroundColor,
                  borderRadius: borderRadius,
                ),
                child: Padding(
                  padding: (isIOS) ?  EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom):EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Visibility(
                        visible: showSlideLine,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: isDarkTheme
                                    ? Colors.grey.shade700
                                    : theme.disabledColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      child,
                    ],
                  ),
                ),
              ),
            );

            return (isIOS) ?  content :   SafeArea(
              child: content
            );
          },
        );
      },
    );
  }
}

