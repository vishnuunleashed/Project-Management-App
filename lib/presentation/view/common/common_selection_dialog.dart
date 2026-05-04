import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';

/// Generic selection dialog with search functionality
/// Can be used for any type of data with name/description field
Future<void> showSelectionDialog<T>(
    BuildContext context, {
      required List<T> items,
      required String Function(T) getDisplayName,
      required void Function(T) onSelect,
      String title = 'Select',
      String searchHint = 'Search',
      bool showSearch = true,
    }) {
  List<T> filteredItems = List.from(items);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredItems = items
        .where((item) =>
        getDisplayName(item).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close,
                              color: Theme.of(context).iconTheme.color),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  if (showSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: BaseTextField(
                        hintText: searchHint,
                        hintTextNeeded: true,
                        controller: searchController,
                        maxLines: 1,
                        onChanged: (val) {
                          setState(() {
                            filterList(val);
                          });
                        },
                      ),
                    ),

                  const Divider(height: 1),

                  // List of items
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                      child: Text(
                        'No items found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _SelectionTile(
                          displayName: getDisplayName(item),
                          onSelect: () => onSelect(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Generic selection tile widget
class _SelectionTile extends StatelessWidget {
  final String displayName;
  final VoidCallback onSelect;

  const _SelectionTile({
    required this.displayName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          displayName,
          style: Theme.of(context)
              .textTheme
              .labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Select',
          icon: Icon(Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: onSelect,
        ),
        onTap: onSelect,
      ),
    );
  }
}

/// Specialized dialog for items with subtitle (like Engineer with email)
Future<void> showSelectionDialogWithSubtitle<T>(
    BuildContext context, {
      required List<T> items,
      required String Function(T) getDisplayName,
      required String Function(T) getSubtitle,
      required void Function(T) onSelect,
      String title = 'Select',
      String searchHint = 'Search',
      bool showSearch = true,
    }) {
  List<T> filteredItems = List.from(items);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredItems = items
        .where((item) =>
    getDisplayName(item).toLowerCase().contains(query.toLowerCase()) ||
        getSubtitle(item).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close,
                              color: Theme.of(context).iconTheme.color),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  if (showSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: BaseTextField(
                        hintText: searchHint,
                        hintTextNeeded: true,
                        controller: searchController,
                        maxLines: 1,
                        onChanged: (val) {
                          setState(() {
                            filterList(val);
                          });
                        },
                      ),
                    ),

                  const Divider(height: 1),

                  // List of items
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                      child: Text(
                        'No items found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _SelectionTileWithSubtitle(
                          displayName: getDisplayName(item),
                          subtitle: getSubtitle(item),
                          onSelect: () => onSelect(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Selection tile with subtitle
class _SelectionTileWithSubtitle extends StatelessWidget {
  final String displayName;
  final String subtitle;
  final VoidCallback onSelect;

  const _SelectionTileWithSubtitle({
    required this.displayName,
    required this.subtitle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          displayName,
          style: Theme.of(context)
              .textTheme
              .labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: 'Select',
          icon: Icon(Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: onSelect,
        ),
        onTap: onSelect,
      ),
    );
  }
}