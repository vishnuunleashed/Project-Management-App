import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';

Future<void> departmentListDialog(
    BuildContext context, {
      required List<String> names,
      required void Function(String name) onForward,
      String title = 'Contacts',
    }) {
  List<String> filteredNames = List.from(names);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredNames = names
        .where((name) =>
    name.toLowerCase().contains(query.toLowerCase()) ||
        "General Department"
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

                  // 🔍 Search Field
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: BaseTextField(
                      hintText: "Search",
                      hintTextNeeded: true,
                      controller: searchController,

                      onChanged: (val) {
                        setState(() {
                          filterList(val);
                        });
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // List of names
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                      itemCount: filteredNames.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final name = filteredNames[index];
                        return _NameTile(
                          name: name,
                          onForward: () => onForward(name),
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

class _NameTile extends StatelessWidget {
  final String name;
  final VoidCallback onForward;

  const _NameTile({required this.name, required this.onForward});

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
          child: Text(
            _initials(name),
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        title: Text(
          name,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Theme.of(context).primaryColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: IconButton(
          tooltip: 'Forward',
          icon: Icon(Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: onForward,
        ),
        onTap: onForward,
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}
