
import 'package:flutter/material.dart';

class ExpandCollapseButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onPressed;
  final double? fontSize;
  final double? iconSize;

  const ExpandCollapseButton({
    super.key,
    required this.isExpanded,
    required this.onPressed,
     this.fontSize,
     this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: iconSize??16,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isExpanded ? 'Collapse' : 'Expand',
                  key: ValueKey<bool>(isExpanded),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: fontSize ?? 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}