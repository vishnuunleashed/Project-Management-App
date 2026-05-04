import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MomDetailCard extends StatelessWidget {
  final String meetingTitle;
  final String? dateTime;
  final String? actionItem;

  const MomDetailCard({
    super.key,
    required this.meetingTitle,
    this.dateTime,
    this.actionItem,
  });

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        /// Card
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0.5,
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Section header
                Text(
                  "MOM DETAILS",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14
                  ),
                ),
                const SizedBox(height: 8),
                /// Icon + Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_note_outlined,
                        size: 16,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        meetingTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Date row
                if (dateTime != null && dateTime!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(dateTime),
                        style: theme.textTheme.labelMedium?.copyWith(
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                /// Action item label
                Text(
                  "ACTION ITEM",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                /// Action item content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: primary,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    actionItem ?? "—",
                    style: theme.textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}