import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Generic multi-select dialog with search functionality
/// Can be used for any type of data with optional image support
Future<void> showMultiSelectDialog<T>(
    BuildContext context, {
      required List<T> items,
      required String Function(T) getId,
      required String Function(T) getDisplayName,
      required void Function(List<String>) onSubmit,
      required List<String> initiallySelected,
      String Function(T)? getSubtitle,
      String Function(T)? getImageUrl,
      String title = 'Select Items',
      String searchHint = 'Search',
      String submitButtonText = 'Submit',
      bool showSearch = true,
    }) {
  List<T> filteredItems = List.from(items);
  final TextEditingController searchController = TextEditingController();
  Set<String> selectedIds = Set.from(initiallySelected);

  void filterList(String query) {
    filteredItems = items.where((item) {
      final nameMatch = getDisplayName(item).toLowerCase().contains(query.toLowerCase());
      final subtitleMatch = getSubtitle != null
          ? getSubtitle(item).toLowerCase().contains(query.toLowerCase())
          : false;
      return nameMatch || subtitleMatch;
    }).toList();
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
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
                                .titleLarge,
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
                          setState(() => filterList(val));
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
                        final itemId = getId(item);

                        return Stack(
                          children: [
                            _MultiSelectTile(
                              displayName: getDisplayName(item),
                              subtitle: getSubtitle?.call(item),
                              imageUrl: getImageUrl?.call(item),
                              onTap: () {
                                setState(() {
                                  if (selectedIds.contains(itemId)) {
                                    selectedIds.remove(itemId);
                                  } else {
                                    selectedIds.add(itemId);
                                  }
                                });
                              },
                            ),

                            // Checkbox at right side
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Checkbox(
                                  value: selectedIds.contains(itemId),
                                  activeColor: bayaInfraGraphBluePrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedIds.add(itemId);
                                      } else {
                                        selectedIds.remove(itemId);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSubmit(selectedIds.toList());
                      },
                      child: Text(submitButtonText),
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

/// Multi-select tile widget with optional image and subtitle
class _MultiSelectTile extends StatelessWidget {
  final String displayName;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  const _MultiSelectTile({
    required this.displayName,
    required this.onTap,
    this.subtitle,
    this.imageUrl,
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
        leading: imageUrl != null
            ? CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: (imageUrl!.isNotEmpty && imageUrl!.trim() != '')
                ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) =>
              const CircularProgressIndicator(),
              errorWidget: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: bayaInfraBlue100,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            )
                : Container(
              width: double.infinity,
              height: double.infinity,
              color: bayaInfraBlue100,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        )
            : null,
        title: Text(
          displayName,
          style: Theme.of(context)
              .textTheme
              .labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        onTap: onTap,
      ),
    );
  }
}