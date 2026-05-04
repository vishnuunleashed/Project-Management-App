
import 'dart:developer';

import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///onChange and initialValue is mandatory
class BaseDatesPicker extends StatelessWidget {
  const BaseDatesPicker(
      {Key? key,
      required this.onChange,
      required this.initialDate,
      this.firstDate,
      this.lastDate,
      this.subtitle = "",
      this.iconColor,
      this.isEnabled = true})
      : super(key: key);

  final Function(DateTime) onChange;
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String subtitle;
  final bool isEnabled;
  final Color? iconColor;
  String _format(DateTime date) => "${DateFormat.yMMMd().format(date)}";
  @override
  Widget build(BuildContext context) {
    return ListTile(

      onTap: !isEnabled
          ?null
          :() {
        showDatePicker(
          initialDatePickerMode: DatePickerMode.day,
          context: context,
          keyboardType: TextInputType.text,

          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(1900, 8),
          lastDate: lastDate ?? DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary:
                      Theme.of(context).primaryColor, // header background color
                  onPrimary: Colors.white,
                  // header text color// body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark, // button text color
                  ),
                ),
                textTheme: TextTheme(
                  bodyLarge: TextStyle(
                    color: Colors.black
                  )
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Colors.black,       // cursor
                  selectionColor: Colors.black26,  // highlight selection
                  selectionHandleColor: Colors.black, // handle
                ),
              ),

              child: child ?? Container(),
            );
          },
        ).then((value) {
          log(value.toString());
          onChange(value!);
        });
      },
      leading: Icon(
        Icons.date_range_outlined,
        color: iconColor ?? bayaInfraTextColorDark,
      ),
      subtitle:Text(_format(initialDate),overflow: TextOverflow.ellipsis,style: Theme.of(context).textTheme.bodySmall,),
      contentPadding: EdgeInsets.zero,
      title:  Text(subtitle,style: Theme.of(context).textTheme.titleSmall,),
    );
  }
}
