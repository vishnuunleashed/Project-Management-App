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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProjectHeaderCard extends ConsumerWidget {
  final String projectName;
  final String locationName;
  final DateTime? endDate;
  final void Function()? onTap;
  const ProjectHeaderCard({super.key,
    this.projectName="",
    this.locationName="",
    this.endDate,
    this.onTap});

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    return Card(
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          width: 0.5,
          color: Theme.of(context).cardColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    projectName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

              ],
            ),
            SizedBox(
              height: 8,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.date_range, color: Theme.of(context).iconTheme.color),
                          ),
                          Expanded(
                            child: Text(
                              "End Date : ${DateFormat('MMM dd, yyyy').format((endDate) ?? DateTime.now())}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleSmall
                            ),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.40),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              locationName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                );
              },
            )


          ],
        ),
      ),
    );
  }
}
