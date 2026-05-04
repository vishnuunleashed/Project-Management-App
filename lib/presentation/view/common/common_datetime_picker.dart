import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [onChange], [initialDate] and [initialTime] are mandatory
class CommonDateTimePicker extends StatelessWidget {
  const CommonDateTimePicker({
    super.key,
    required this.onChange,
    this.initialDate,
    this.initialTime,
    this.firstDate,
    this.lastDate,
    this.label = "",
    this.labelColor,
    this.borderColor,
    this.iconColor,
    this.isEnabled = true,
    this.readOnly = false,
  });

  final Function(DateTime) onChange;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;
  final Color? labelColor;
  final Color? borderColor;
  final bool isEnabled;
  final Color? iconColor;
  final bool readOnly;

  String _formatDate(DateTime date) => DateFormat("dd/MM/yyyy").format(date);

  String _formatTime(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

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

    return pickerInitial.isBefore(pickerFirst) ? pickerFirst : pickerInitial;
  }

  Future<void> _onTap(BuildContext context) async {
    // Step 1: Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      keyboardType: TextInputType.text,
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
                foregroundColor: Theme.of(context).primaryColorDark,
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.black26,
              selectionHandleColor: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate == null) return;

    // Step 2: Pick time
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialDate != null
          ? TimeOfDay.fromDateTime(initialDate!)
          : initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).primaryColor;
                }
                return Colors.grey.shade200;
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return Colors.black;
              }),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white// text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // Combine date + time into a single DateTime
    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onChange(combined);
  }

  @override
  Widget build(BuildContext context) {
    // Derive display values — time is read from initialDate so callers don't
    // need to pass a separate initialTime parameter.
    final String dateText =
    initialDate != null ? _formatDate(initialDate!) : "Select date";
    final TimeOfDay? derivedTime =
    initialDate != null ? TimeOfDay.fromDateTime(initialDate!) : initialTime;
    final String timeText =
    derivedTime != null ? _formatTime(derivedTime) : "Select time";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              color: (isEnabled || readOnly)
                  ? Theme.of(context).colorScheme.primary
                  : borderColor ??
                  Theme.of(context).disabledColor.withValues(alpha: .5),
              width: 0.54,
            ),
          ),
          color: Theme.of(context).cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: !isEnabled ? null : () => _onTap(context),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date section
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: (isEnabled || readOnly)
                            ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 155)
                            : Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 128),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: (isEnabled || readOnly)
                              ? Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.color
                              : bayaInfraGreyColor,
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Container(
                    height: 20,
                    width: 0.54,
                    color: (isEnabled || readOnly)
                        ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 100)
                        : Theme.of(context)
                        .disabledColor
                        .withValues(alpha: 80),
                  ),

                  // Time section
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: (isEnabled || readOnly)
                            ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 155)
                            : Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 128),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeText,
                        style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: (isEnabled || readOnly)
                              ? Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.color
                              : bayaInfraGreyColor,
                        ),
                      ),
                    ],
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