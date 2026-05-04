import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';

// ── Drag handle ───────────────────────────────────────────────────────────────
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
// ── Action item banner ────────────────────────────────────────────────────────
class ActionItemBanner extends StatelessWidget {
  final String? actionItem;
  final String? ownerName;

  const ActionItemBanner({
    super.key,
    required this.actionItem,
    this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label row ────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.task_alt_outlined, size: 13, color: primary),
                const SizedBox(width: 5),
                Text(
                  'ACTION ITEM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Action item title ─────────────────────────────────────
            Text(
              actionItem ?? '',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // ── Owner chip ────────────────────────────────────────────
            if (ownerName != null && ownerName!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ownerName!,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Count badge ───────────────────────────────────────────────────────────────
class CountBadge extends StatelessWidget {
  final int count;
  final Color bg;
  final Color fg;
  const CountBadge({super.key, required this.count, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}


// ── Sticky bottom bar ─────────────────────────────────────────────────────────
class StickyBottomBar extends StatelessWidget {
  final MediaQueryData mq;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const StickyBottomBar({super.key,
    required this.mq,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + mq.padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: BaseElevatedButton(
              onPressed: onCancel,
              text: cancelLabel,
              backgroundColor: bayaInfraDisabledColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: BaseElevatedButton(
              onPressed: onConfirm,
              text: confirmLabel,
            ),
          ),
        ],
      ),
    );
  }
}