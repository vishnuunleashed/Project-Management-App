import 'package:flutter/material.dart';

class ThemedTabBar extends StatefulWidget {
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int>? onTabSelected;
  final int initialIndex;

  const ThemedTabBar({
    super.key,
    required this.icons,
    required this.labels,
    this.initialIndex = 0,
    this.onTabSelected
  });

  @override
  State<ThemedTabBar> createState() => _ThemedTabBarState();
}

class _ThemedTabBarState extends State<ThemedTabBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(ThemedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state if initialIndex changed from outside
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  void _onTabTap(int index) {
    setState(() =>  _selectedIndex = index);
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: List.generate(widget.icons.length, (index) {
        final bool isSelected = _selectedIndex == index;

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTabTap(index),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedPhysicalModel(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                shadowColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                elevation: isSelected ? 1 : 0.5,
                borderRadius: BorderRadius.circular(12),
                shape: BoxShape.rectangle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icons[index],
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.labels[index],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.color
                            ?.withOpacity(0.5),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}