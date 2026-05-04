/*------------------------------------------------------------------------------
AUTHOR		    : Karan Sreyas
CREATED DATE	: 08/08/2025
PURPOSE		    : Settings Provider
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/presentation/provider/settings/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeSetting extends StatelessWidget {
  final SettingsProvider value;

  const ThemeSetting({super.key, required this.value});


  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          side: BorderSide(color: themeData.disabledColor),
        ),
        color: themeData.cardColor,
        child: ExpansionTile(
          trailing: value.isExpaned
              ? RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    Icons.chevron_right_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
              )
              : RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.chevron_right_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
              ),
          onExpansionChanged: (expanded) {
            value.changeExpandFlagStatus(expanded);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          collapsedIconColor: Theme.of(context).secondaryHeaderColor,
          iconColor: Theme.of(context).secondaryHeaderColor,
          leading: Icon(
            CupertinoIcons.gear,
            color: value.isExpaned
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.labelMedium?.color,
          ),
          title: Text(
            "Theme Settings",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: value.isExpaned
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.labelMedium?.color),
          ),
          children: [
            // ── Colour Picker ─────────────────────────────────────────────
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: themeData.highlightColor,
            //       borderRadius: const BorderRadius.all(Radius.circular(15)),
            //     ),
            //     padding: const EdgeInsets.all(12),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           "Colour Theme",
            //           style: themeData.textTheme.bodyLarge,
            //         ),
            //         const SizedBox(height: 4),
            //         Text(
            //           "Choose the accent colour for the app.",
            //           style: themeData.textTheme.bodyMedium,
            //         ),
            //         const SizedBox(height: 12),
            //
            //         // 5 swatches in a wrap so they reflow on small screens
            //         // REPLACE with this:
            //         Wrap(
            //           spacing: 10,
            //           runSpacing: 10,
            //           children: AppThemeVariant.values.map((variant) {
            //             final isSelected = currentVariant == variant;
            //             return GestureDetector(
            //               onTap: () => _applyVariant(context, variant),  // use outer context
            //               child: SizedBox(
            //                 // ... rest of your swatch widget unchanged
            //               ),
            //             );
            //           }).toList(),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),

            // ── Dark / Light / System radios ──────────────────────────────
            _modeRadio(
              context: context,
              title: "Dark Theme",
              subtitle: "Reduces screen brightness with dark backgrounds.",
              mode: ThemeMode.dark,
              onChanged: (_) => value.changeTheme(ThemeConfig.dark),
            ),
            _modeRadio(
              context: context,
              title: "Light Theme",
              subtitle: "Uses a bright background with dark text.",
              mode: ThemeMode.light,
              onChanged: (_) => value.changeTheme(ThemeConfig.light),
            ),
            _modeRadio(
              context: context,
              title: "System Theme",
              subtitle: "Matches your device's system setting.",
              mode: ThemeMode.system,
              onChanged: (_) => value.changeTheme(ThemeConfig.auto),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: single radio tile ─────────────────────────────────────────────
  Widget _modeRadio({
    required BuildContext context,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: themeData.highlightColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text(
              title,
              style: themeData.textTheme.titleMedium,
            ),
            subtitle: Text(subtitle, style: themeData.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w300
            )),
            trailing: Radio<ThemeMode>(
              value: mode,
              groupValue: value.currentTheme,
              activeColor: themeData.primaryColor,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}