import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';

Future<void> showOwnerMultiSelectDialog(
    BuildContext context, {
      required List<OwnerModel> ownersList,
      required void Function(List<String> names) onForward,
      required List<String> initiallySelected,
      String title = 'Owners',
    }) {
  List<OwnerModel> filteredNames = List.from(ownersList);
  final TextEditingController searchController = TextEditingController();

  Set<String> selectedNames = Set.from(initiallySelected);

  void filterList(String query) {
    filteredNames = ownersList
        .where((owner) => owner.name
        .toString()
        .toLowerCase()
        .contains(query.toLowerCase()))
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
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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

                  // Search
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: BaseTextField(
                      hintText: "Search",
                      hintTextNeeded: true,
                      controller: searchController,
                      maxLines: 1,
                      onChanged: (val) {
                        setState(() => filterList(val));
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      itemCount: filteredNames.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredNames[index];

                        return Stack(
                          children: [
                            _NameTile(
                              name: item.name ,
                              onSubmit: () {
                                // SINGLE TAP → Toggle selection
                                setState(() {
                                  if (selectedNames.contains(item.name)) {
                                    selectedNames.remove(item.name);
                                  } else {
                                    selectedNames.add(item.name);
                                  }
                                });
                              },
                            ),

                            /// Checkbox at right side
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Checkbox(
                                  value:
                                  selectedNames.contains(item.name),
                                  activeColor: bayaInfraGraphBluePrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedNames.add(item.name );
                                      } else {
                                        selectedNames.remove(item.name );
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

                  ///  Bottom button (new)
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
                        onForward(selectedNames.toList()); // return list
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

class _NameTile extends StatelessWidget {
  final String name;
  final VoidCallback onSubmit;

  const _NameTile({required this.name, required this.onSubmit});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
