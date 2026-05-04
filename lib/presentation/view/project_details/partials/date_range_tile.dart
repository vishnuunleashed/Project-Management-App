/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:flutter/material.dart';

class DateRangeTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? selectedRange;

  const DateRangeTile({
    super.key,
    required this.label,
    required this.onTap,
    required this.selectedRange,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRange == label;

    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : const Icon(Icons.arrow_forward),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      onTap: onTap,
    );
  }
}
