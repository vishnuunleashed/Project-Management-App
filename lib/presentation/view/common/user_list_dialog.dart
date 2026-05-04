import 'package:base/presentation/views/base_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';

Future<void> showUserListDialog(
    BuildContext context, {
      required List<OwnerModel> userList,
      required void Function(String name) onForward,
      String title = 'Owners list',
    }) {
  List<OwnerModel> filteredNames = List.from(userList);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredNames = userList
        .where((user) =>
    user.name
        .toString()
        .toLowerCase()
        .contains(query.toLowerCase()) ||
        user.departmentName.toLowerCase().contains(query.toLowerCase()))
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
                            style: Theme.of(context).textTheme.titleMedium,
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
                      maxLines: 1,

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
                          name: name.name,
                          imageUrl: name.profileurl,
                          department: name.departmentName,
                          onForward: () => onForward(name.name),
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
  final String imageUrl;
  final VoidCallback onForward;
  final String department;

  const _NameTile({required this.name, required this.imageUrl, required this.department, required this.onForward});

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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          style: Theme.of(context).textTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text(
          department,
          style: Theme.of(context).textTheme.bodySmall,
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
}

