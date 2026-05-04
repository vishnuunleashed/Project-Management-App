import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';

Future<void> showSiteMultiSelectDialog(
  BuildContext context, {
  required List<SiteModel> siteList,
  required void Function(List<String> names) onForward,
  required List<String> initiallySelected,
  String title = 'Site',
}) {
  final theme = Theme.of(context);
  List<SiteModel> filteredSites = List.from(siteList);
  final TextEditingController searchController = TextEditingController();

  Set<String> selectedNames = Set.from(initiallySelected);

  void filterList(String query) {
    filteredSites = siteList
        .where(
            (site) => site.siteName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  return showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: theme.dialogTheme.backgroundColor,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: Column(
                children: [
                  /// Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: theme.iconTheme.color),
                        ),
                      ],
                    ),
                  ),

                  /// Search
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: BaseTextField(
                      hintText: "Search Site",
                      hintTextNeeded: true,
                      controller: searchController,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() => filterList(val));
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  /// List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      itemCount: filteredSites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredSites[index];

                        return Stack(
                          children: [
                            _SiteTile(
                              name: item.siteName,
                              address: item.address,
                              onSubmit: () {
                                setState(() {
                                  if (selectedNames.contains(item.siteName)) {
                                    selectedNames.remove(item.siteName);
                                  } else {
                                    selectedNames.add(item.siteName);
                                  }
                                });
                              },
                            ),

                            /// Checkbox
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Checkbox(
                                  value: selectedNames.contains(item.siteName),
                                  activeColor: bayaInfraGraphBluePrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedNames.add(item.siteName);
                                      } else {
                                        selectedNames.remove(item.siteName);
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

                  /// Submit Button
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
                        onForward(selectedNames.toList());
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
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

class _SiteTile extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onSubmit;

  const _SiteTile({
    required this.name,
    required this.address,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          name,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onSubmit,
      ),
    );
  }
}
