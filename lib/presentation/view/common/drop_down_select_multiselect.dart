import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';

Future<void> showUserListDialogMultiSelect(
    BuildContext context, {
      required List<OwnerModel> userList,
      required void Function(List<String> names) onForward,
      required List<String> initiallySelected,
      String title = 'Owners list',
    }) {
  List<OwnerModel> filteredNames = List.from(userList);
  final TextEditingController searchController = TextEditingController();

  Set<String> selectedNames = Set.from(initiallySelected);

  void filterList(String query) {
    filteredNames = userList
        .where((user) =>
    user.name.toString().toLowerCase().contains(query.toLowerCase()) ||
        user.departmentName.toLowerCase().contains(query.toLowerCase()))
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

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredNames[index];

                        return Stack(
                          children: [
                            _NameTile(
                              name: item.name,
                              department: item.departmentName,
                              imageUrl: item.profileurl,
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
                                  value: selectedNames.contains(item.name),
                                  activeColor: bayaInfraGraphBluePrimary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedNames.add(item.name);
                                      } else {
                                        selectedNames.remove(item.name);
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

                  /// ⬇️ Bottom button (new)
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
                      child: const Text("Submit", style: TextStyle(color: Colors.white),),
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
  final String imageUrl;
  final VoidCallback onSubmit;
  final String department;

  const _NameTile({required this.name, required this.imageUrl, required this.department, required this.onSubmit});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).primaryColor,
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: (imageUrl.isNotEmpty && imageUrl.trim() != '')
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, error, stackTrace) => _buildPlaceholder(context),
            )
                : _buildPlaceholder(context),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context)
              .textTheme
              .labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text(
          department,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        onTap: onSubmit,
      ),
    );
  }
}
