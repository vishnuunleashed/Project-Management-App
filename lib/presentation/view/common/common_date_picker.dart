import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// onChange and initialDate are mandatory
class CommonDatesPicker extends StatelessWidget {
  const CommonDatesPicker({
    super.key,
    required this.onChange,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.label = "",
    this.labelColor,
    this.borderColor,
    this.iconColor,
    this.isEnabled = true,
  });

  final Function(DateTime) onChange;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;
  final Color? labelColor;
  final Color? borderColor;
  final bool isEnabled;
  final Color? iconColor;

  String _format(DateTime date) => DateFormat("dd/MM/yyyy").format(date);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _resolvePickerInitialDate() {
    final DateTime today = DateTime.now();

    if (initialDate == null) {
      if (firstDate != null && today.isBefore(firstDate!)) {
        return firstDate!;
      }
      return today;
    }

    if (firstDate == null) return initialDate!;

    final DateTime pickerInitial = _dateOnly(initialDate!);
    final DateTime pickerFirst = _dateOnly(firstDate!);

    return pickerInitial.isBefore(pickerFirst)
        ? pickerFirst
        : pickerInitial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                color: labelColor,
              ),
            ),
          ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : borderColor ??
                  Theme.of(context)
                      .disabledColor
                      .withValues(alpha: .5),
              width: 0.54,
            ),
          ),
          color: Theme.of(context).cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: !isEnabled
                ? null
                : () {
              showDatePicker(
                context: context,
                initialDatePickerMode: DatePickerMode.day,
                keyboardType: TextInputType.text,

                /// 🔑 SAFETY FIX (internal only)
                initialDate: _resolvePickerInitialDate(),

                firstDate: firstDate ?? DateTime(1900, 8),
                lastDate: lastDate ?? DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor:
                          Theme.of(context).primaryColorDark,
                        ),
                      ),
                      textTheme: const TextTheme(
                        bodyLarge: TextStyle(color: Colors.black),
                      ),
                      textSelectionTheme:
                      const TextSelectionThemeData(
                        cursorColor: Colors.black,
                        selectionColor: Colors.black26,
                        selectionHandleColor: Colors.black,
                      ),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ).then((value) {
                if (value != null) {
                  onChange(value);
                }
              });
            },
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// DISPLAY DATE — untouched
                  Text(
                    initialDate != null ? _format(initialDate!) : "Select date",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isEnabled
                          ? Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.color
                          : bayaInfraGreyColor,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: isEnabled
                        ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 155)
                        : Theme.of(context)
                        .disabledColor
                        .withValues(alpha: 128),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
