import 'package:flutter/material.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';

class DccBreadcrumb extends StatelessWidget {
  final List<DccFolderModel> breadcrumb;
  final Function(int index) onTapBreadcrumb;
  final VoidCallback onTapRoot;

  const DccBreadcrumb({
    super.key,
    required this.breadcrumb,
    required this.onTapBreadcrumb,
    required this.onTapRoot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Center(
            child: _BreadcrumbItem(
              label: 'Home',
              isActive: breadcrumb.isEmpty,
              onTap: onTapRoot,
              theme: theme,
              isDark: isDark,
            ),
          ),
          ...breadcrumb.asMap().entries.map((entry) {
            final isLast = entry.key == breadcrumb.length - 1;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: theme.iconTheme.color?.withOpacity(0.3)),
                ),
                _BreadcrumbItem(
                  label: entry.value.name,
                  isActive: isLast,
                  onTap: () => onTapBreadcrumb(entry.key),
                  theme: theme,
                  isDark: isDark,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _BreadcrumbItem({required this.label, required this.isActive, required this.onTap, required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF4A6580).withOpacity(0.08)) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? theme.textTheme.titleMedium?.color : theme.textTheme.titleLarge?.color,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
