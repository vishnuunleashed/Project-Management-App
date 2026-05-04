import 'package:flutter/material.dart';

class CustomBottomBar extends StatefulWidget {
  final ValueChanged<int> onTabSelected;
  final int initialIndex;

  const CustomBottomBar({
    super.key,
    required this.onTabSelected,
    this.initialIndex = 0,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  late int _selectedIndex;

  final List<String> _titles = [
    "Dashboard",
    "Project List",
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.assignment,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() => _selectedIndex = widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF3B82F6); // Blue-500
    final Color inactiveColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_titles.length, (index) {
            final bool isSelected = _selectedIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  widget.onTabSelected(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[index],
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _titles[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected ? activeColor : inactiveColor,
                          fontWeight: null,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
