import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/project_schedule/task_type_dropdown_model.dart';

Future<void> scheduleTypeListDialog(
    BuildContext context, {
      required List<TaskTypeDropdownDtlModel> taskTypeList,
      required void Function(TaskTypeDropdownDtlModel) onForward,
      String title = 'Schedule Type',
    }) {
  List<TaskTypeDropdownDtlModel> filteredTask = List.from(taskTypeList);
  final TextEditingController searchController = TextEditingController();

  void filterList(String query) {
    filteredTask = taskTypeList
        .where((name) =>
    (name.taskTypeDescription ?? "").toLowerCase().contains(query.toLowerCase()))
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
                      itemCount: filteredTask.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = filteredTask[index];
                        return _NameTile(
                          name: task.taskTypeDescription ?? "",
                          onForward: () => onForward(task),
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
          tooltip: 'Select',
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
