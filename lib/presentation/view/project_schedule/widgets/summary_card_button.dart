import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class ScheduleHealthCard extends StatelessWidget {
  final Color statusColor;
  final String title;
  final String message;
  final VoidCallback onTap;

  const ScheduleHealthCard({
    super.key,
    required this.statusColor,
    required this.title,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: statusColor.withValues(alpha: 0.15),
        highlightColor: statusColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: statusColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.labelLarge?.copyWith(
                        color: bayaInfraBlue600
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: textTheme.labelMedium?.copyWith(
                          color: statusColor
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.open_in_new,
                size: 18,
                color: Theme.of(context).iconTheme.color
              ),
            ],
          ),
        ),
      ),
    );
  }
}
