import 'package:flutter/material.dart';

class TabListView extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> tabLabels;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const TabListView({
    Key? key,
    required this.scrollController,
    required this.tabLabels,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<TabListView> createState() => _TabListViewState();
}

class _TabListViewState extends State<TabListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: widget.tabLabels.length,
      itemBuilder: (context, index) {
        final isSelected = widget.selectedIndex == index;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () => widget.onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.hintColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.textTheme.bodyLarge!.color!.withOpacity(0.5),
                  width: isSelected ? 1 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  widget.tabLabels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}