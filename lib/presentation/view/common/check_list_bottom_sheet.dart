import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

class _Tokens {
  static const radiusSheet = Radius.circular(24.0);
  static const radiusCard = BorderRadius.all(Radius.circular(14.0));
  static const radiusChip = BorderRadius.all(Radius.circular(6.0));
  static const radiusCheck = BorderRadius.all(Radius.circular(6.0));

  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;

  static const durationFast = Duration(milliseconds: 180);
  static const durationMed = Duration(milliseconds: 260);

  static const colorRequired = Color(0xFFFF6B35);
  static const colorDone = Color(0xFF22C55E);
  static const colorDanger = Color(0xFFEF4444);
  static const colorDangerBorder = Color(0xFFFFCDD0);
  static const colorHandle = Color(0xFFE0E0E0);
}

// ─── Bottom Sheet Launcher ────────────────────────────────────────────────────

void showChecklistBottomSheet(
    BuildContext context, {
      required List<CheckListModel> items,
      bool isCompleted = false,
      String title = 'Project Schedule Checklist',
      String subtitle = 'Check and confirm each item',
      Function(List<CheckListModel>)? onReviewed,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => ChecklistBottomSheet(
      items: items,
      isCompleted: isCompleted,
      title: title,
      subtitle: subtitle,
      onReviewed: onReviewed,
    ),
  );
}

// ─── Checklist Bottom Sheet ───────────────────────────────────────────────────

class ChecklistBottomSheet extends StatefulWidget {
  final List<CheckListModel> items;
  final bool isCompleted;
  final String title;
  final String subtitle;
  final Function(List<CheckListModel>)? onReviewed;

  const ChecklistBottomSheet({
    super.key,
    required this.items,
    required this.isCompleted,
    required this.title,
    required this.subtitle,
    this.onReviewed,
  });

  @override
  State<ChecklistBottomSheet> createState() => _ChecklistBottomSheetState();
}

class _ChecklistBottomSheetState extends State<ChecklistBottomSheet>
    with SingleTickerProviderStateMixin {
  /// Working duplicate — all tick/untick actions happen here.
  /// [widget.items] (the original list) is never mutated.
  late List<CheckListModel> _items;

  final Set<int> _invalidIds = {};
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Creates a fresh deep-copy of the original list.
  List<CheckListModel> _copyOriginal() =>
      widget.items.map((e) => e.copyWith()).toList();

  /// Resets the working duplicate back to the original state.
  void _resetToOriginal() {
    setState(() {
      _items = _copyOriginal();
      _invalidIds.clear();
    });
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Start with a copy so the original is never touched from the beginning.
    _items = _copyOriginal();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ── Derived state ──────────────────────────────────────────────────────────

  int get _total => _items.length;
  int get _done => _items.where((it) => it.isChecked).length;
  int _id(CheckListModel item) => item.checklistId ?? item.hashCode;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _toggle(CheckListModel item) {
    setState(() {
      item.isChecked = !item.isChecked;
      if (item.isChecked) _invalidIds.remove(_id(item));
    });
  }

  /// On submit: validate mandatory items (when isCompleted), call [onReviewed]
  /// with the duplicate list, then reset the duplicate back to the original.
  void _submit() {
    if (widget.isCompleted) {
      final unchecked = _items
          .where((it) => it.isMandatory && !it.isChecked)
          .map(_id)
          .toSet();
      if (unchecked.isNotEmpty) {
        setState(() {
          _invalidIds
            ..clear()
            ..addAll(unchecked);
        });
        _shakeController.forward(from: 0);
        return;
      }
    }

    widget.onReviewed?.call(_items);
    _resetToOriginal(); // restore duplicate to original state before closing
    Navigator.pop(context);
  }

  /// On close: discard changes and restore duplicate to original state.
  void _close() {
    _resetToOriginal();
    Navigator.pop(context);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final progress = _total == 0 ? 0.0 : _done / _total;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => _SheetScaffold(
          backgroundColor: bg,
          header: _SheetHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            total: _total,
            done: _done,
            progress: progress,
          ),
          body: ListView.separated(
            controller: controller,
            padding: const EdgeInsets.symmetric(
              horizontal: _Tokens.spacingMd,
              vertical: _Tokens.spacingMd,
            ),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: _Tokens.spacingSm),
            itemBuilder: (_, i) {
              final item = _items[i];
              return _ChecklistTile(
                item: item,
                isInvalid: _invalidIds.contains(_id(item)),
                onToggle: () => _toggle(item),
              );
            },
          ),
          footer: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (_, child) => Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            ),
            child: _SheetFooter(
              onClose: _close,   // ← uses _close instead of Navigator.pop
              onSubmit: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sheet Scaffold ───────────────────────────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  final Color backgroundColor;
  final Widget header;
  final Widget body;
  final Widget footer;

  const _SheetScaffold({
    required this.backgroundColor,
    required this.header,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: _Tokens.radiusSheet),
      ),
      child: Column(
        children: [
          const _DragHandle(),
          header,
          const _Divider(),
          Expanded(child: body),
          const _Divider(),
          footer,
        ],
      ),
    );
  }
}

// ─── Drag Handle ─────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: _Tokens.colorHandle,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
    );
  }
}

// ─── Sheet Header ─────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int total;
  final int done;
  final double progress;

  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.done,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final allDone = done == total && total > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _Tokens.spacingLg,
        _Tokens.spacingMd,
        _Tokens.spacingLg,
        _Tokens.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(primary: primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProgressChip(progress: progress, allDone: allDone, primary: primary),
            ],
          ),
          const SizedBox(height: _Tokens.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$done of $total completed',
                style: textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (allDone)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: _Tokens.colorDone,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'All complete',
                      style: textTheme.labelSmall?.copyWith(
                        color: _Tokens.colorDone,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: _Tokens.spacingMd),
          _SegmentedProgress(total: total, done: done, primary: primary),
        ],
      ),
    );
  }
}

// ─── Icon Badge ───────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final Color primary;

  const _IconBadge({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.checklist_rounded, size: 20, color: primary),
    );
  }
}

// ─── Progress Chip ────────────────────────────────────────────────────────────

class _ProgressChip extends StatelessWidget {
  final double progress;
  final bool allDone;
  final Color primary;

  const _ProgressChip({
    required this.progress,
    required this.allDone,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final color = allDone ? _Tokens.colorDone : primary;
    return AnimatedContainer(
      duration: _Tokens.durationMed,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Segmented Progress Bar ───────────────────────────────────────────────────

class _SegmentedProgress extends StatelessWidget {
  final int total;
  final int done;
  final Color primary;

  const _SegmentedProgress({
    required this.total,
    required this.done,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final allDone = done == total;
    const gap = 3.0;

    return LayoutBuilder(builder: (context, constraints) {
      final segW = (constraints.maxWidth - gap * (total - 1)) / total;
      return Row(
        children: List.generate(total, (i) {
          final filled = i < done;
          return Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? gap : 0),
            child: AnimatedContainer(
              duration: _Tokens.durationMed,
              curve: Curves.easeOut,
              width: segW,
              height: 5,
              decoration: BoxDecoration(
                color: filled
                    ? (allDone ? _Tokens.colorDone : primary)
                    : primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          );
        }),
      );
    });
  }
}

// ─── Sheet Footer ─────────────────────────────────────────────────────────────

class _SheetFooter extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  const _SheetFooter({required this.onClose, required this.onSubmit});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _Tokens.spacingMd,
        _Tokens.spacingMd,
        _Tokens.spacingMd,
        _Tokens.spacingMd + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: BaseElevatedButton(
                backgroundColor: bayaInfraDisabledColor,
                onPressed: onClose,
                text: 'Close'
            ),
          ),
          const SizedBox(width: _Tokens.spacingSm),
          Expanded(
            child: BaseElevatedButton(
              onPressed: onSubmit,
              text:'Ok',
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Checklist Tile ───────────────────────────────────────────────────────────

class _ChecklistTile extends StatelessWidget {
  final CheckListModel item;
  final bool isInvalid;
  final VoidCallback onToggle;

  const _ChecklistTile({
    required this.item,
    required this.isInvalid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final checked = item.isChecked;
    final mandatory = item.isMandatory;
    final name = item.name ?? '';
    final textTheme = Theme.of(context).textTheme;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Color borderColor;
    Color bgColor;

    if (isInvalid) {
      borderColor = _Tokens.colorDangerBorder;
      bgColor = surface;
    } else if (checked) {
      borderColor = onSurface.withValues(alpha: 0.07);
      bgColor = onSurface.withValues(alpha: 0.025);
    } else {
      borderColor = onSurface.withValues(alpha: 0.10);
      bgColor = surface;
    }

    return AnimatedContainer(
      duration: _Tokens.durationMed,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: _Tokens.radiusCard,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _Tokens.radiusCard,
        child: InkWell(
          onTap: onToggle,
          borderRadius: _Tokens.radiusCard,
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _Tokens.spacingMd,
              vertical: 13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _AnimatedCheckbox(checked: checked),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: _Tokens.durationFast,
                              style: (textTheme.titleMedium ?? const TextStyle())
                                  .copyWith(
                                fontWeight:
                                checked ? FontWeight.w400 : FontWeight.w600,
                                color: checked
                                    ? onSurface.withValues(alpha: 0.60)
                                    : onSurface,
                                decorationColor: onSurface.withValues(alpha: 0.25),
                                decorationThickness: 1.5,
                              ),
                              child: Text(name),
                            ),
                          ),
                          if (mandatory) ...[
                            const SizedBox(width: 10),
                            _StatusChip(
                              checked: checked,
                              isInvalid: isInvalid,
                            ),
                          ],
                        ],
                      ),
                      if (isInvalid) ...[
                        const SizedBox(height: 6),
                        _ValidationMessage(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool checked;
  final bool isInvalid;

  const _StatusChip({required this.checked, required this.isInvalid});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;

    if (isInvalid) {
      bgColor = _Tokens.colorDanger.withValues(alpha: 0.10);
      textColor = _Tokens.colorDanger;
      label = 'Required';
    } else if (checked) {
      bgColor = _Tokens.colorDone.withValues(alpha: 0.10);
      textColor = _Tokens.colorDone;
      label = 'Done';
    } else {
      bgColor = _Tokens.colorRequired.withValues(alpha: 0.10);
      textColor = _Tokens.colorRequired;
      label = 'Required';
    }

    return AnimatedContainer(
      duration: _Tokens.durationMed,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: _Tokens.radiusChip,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Validation Message ───────────────────────────────────────────────────────

class _ValidationMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 12,
          color: _Tokens.colorDanger,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'This item must be checked before submitting the task.',
            style: TextStyle(
              fontSize: 11,
              color: _Tokens.colorDanger,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Animated Checkbox ────────────────────────────────────────────────────────

class _AnimatedCheckbox extends StatelessWidget {
  final bool checked;

  const _AnimatedCheckbox({required this.checked});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: _Tokens.durationMed,
      curve: Curves.easeOut,
      width: 21,
      height: 21,
      decoration: BoxDecoration(
        color: checked ? primary : Colors.transparent,
        border: Border.all(
          color: checked
              ? primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          width: 1.5,
        ),
        borderRadius: _Tokens.radiusCheck,
      ),
      child: checked
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}