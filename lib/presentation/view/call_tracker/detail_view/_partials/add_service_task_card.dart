import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/pdf_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'google_docs_viewer_screen.dart';
import 'network_image_view_screen.dart';

class AddServiceTaskCard extends ConsumerStatefulWidget {
  final ServiceTaskModel task;
  final int taskIndex;
  final ServiceTasksProvider provider;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AddServiceTaskCard({
    super.key,
    required this.task,
    required this.taskIndex,
    required this.provider,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  ConsumerState<AddServiceTaskCard> createState() => _AddServiceTaskCardState();
}

class _AddServiceTaskCardState extends ConsumerState<AddServiceTaskCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final taskIndex = widget.taskIndex;
    final provider = widget.provider;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseConsumer(
      provider: addServiceRequestProvider,
      builder: (context,provider,ref) {
        return GestureDetector(
          onTap: widget.onEdit,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Always-visible header row ──────────────────────────
                      // ── Always-visible header row ──────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// ── Header band ─────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// Serial number chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "T${taskIndex + 1}",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: bayaInfraWhiteColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const Spacer(),


                                const SizedBox(width: 6),
                                /// Actions
                                Row(
                                  children: [
                                    /// Edit button
                                    GestureDetector(
                                      onTap: widget.onEdit,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    /// Delete button
                                    GestureDetector(
                                      onTap: () async {
                                        final router = GoRouter.of(context);
                                        BaseDialog.show(
                                          context: context,
                                          title: "Confirm",
                                          message: "Do you want to remove this task?",
                                          actions: [
                                            Row(
                                              spacing: 4,
                                              children: [
                                                Expanded(
                                                  child: BaseElevatedButton(
                                                    fontWeight: FontWeight.w700,
                                                    borderRadius: 24,
                                                    backgroundColor: bayaInfraDisabledColor,
                                                    onPressed: () => router.pop(),
                                                    text: "Cancel",
                                                  ),
                                                ),
                                                Expanded(
                                                  child: BaseElevatedButton(
                                                    fontWeight: FontWeight.w700,
                                                    borderRadius: 24,
                                                    backgroundColor: Theme.of(context).primaryColor,
                                                    onPressed: () {
                                                      router.pop();
                                                      widget.onDelete();
                                                    },
                                                    text: 'Remove',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.error.withValues(alpha:  0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(Icons.delete_outline, size: 18, color: bayaInfraRed),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          ),


                          /// ── Description — full width, no siblings ────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Description',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.description ?? '',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          if ((task.assignedUser ?? '').isNotEmpty ||
                              (task.targetclosuredate ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if ((task.assignedUser ?? '').isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Task Owner',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          task.assignedUser ?? '',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  if ((task.targetclosuredate ?? '').isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Target Closure Date',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          task.targetclosuredate == null ||
                                                  task.targetclosuredate!.isEmpty
                                              ? ""
                                              : DateFormat('dd-MM-yyyy').format(
                                                  DateTime.parse(
                                                      task.targetclosuredate ??
                                                          DateTime.now().toString())),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      if (task.attachments.isNotEmpty || task.submittedAttachments.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            /// Attachments title container
                            Expanded(
                              child: InkWell(
                                onTap: _toggleExpanded,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file_rounded,
                                        size: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Attachments",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            /// Expand / Collapse button container
                            InkWell(
                              onTap: _toggleExpanded,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // ── Expandable details section ─────────────────────────
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              const SizedBox(height: 6),

                              /// Attachments
                              if (task.attachments.isNotEmpty) ...[
                                const Divider(height: 0.4),
                                const SizedBox(height: 6),
                                Text(
                                  'Task attachments',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _AttachmentsRow(
                                  task: task,
                                  provider: provider,
                                ),
                              ],

                              /// Submitted Attachments
                              if (task.submittedAttachments.isNotEmpty) ...[
                                const Divider(height: 0.4),
                                const SizedBox(height: 6),
                                Text(
                                  'Submitted attachments',
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                _AttachmentsRow(
                                  task: ServiceTaskModel(
                                    attachments: task.submittedAttachments,
                                  ),
                                  provider: provider,
                                ),
                              ],

                              /// Previous Attachments
                              if (task.prevSubmittedAttachments.isNotEmpty) ...[
                                const Divider(height: 0.4),
                                const SizedBox(height: 6),
                                Text(
                                  'Previously submitted attachments',
                                  style: theme.textTheme.titleSmall,
                                  ),
                                const SizedBox(height: 8),
                                _AttachmentsRow(
                                  task: ServiceTaskModel(
                                    attachments: task.prevSubmittedAttachments,
                                  ),
                                  provider: provider,
                                ),
                              ],
                            ],
                        ),
                      ),
                      const SizedBox(height: 12),

                                    const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: BaseLoadingView(
                  message: provider.loadingStatus.message,
                  progress: provider.loadingProgress,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class _AttachmentsRow extends StatelessWidget {
  final ServiceTaskModel task;
  final ServiceTasksProvider provider;

  const _AttachmentsRow({
    required this.task,
    required this.provider,
  });

  static _FileTypeStyle _styleFor(String hint) {
    switch (hint) {
      case 'pdf':
        return const _FileTypeStyle('assets/png/pdf.png', Color(0xFFE74C3C));
      case 'xls':
        return const _FileTypeStyle('assets/png/excel.png', Color(0xFF27AE60));
      case 'doc':
        return const _FileTypeStyle('assets/png/doc.png', Color(0xFF2980B9));
      case 'image':
        return const _FileTypeStyle('assets/png/image.png', Color(0xFF6366F1));
      default:
        return const _FileTypeStyle('assets/png/file.png', Color(0xFF8E44AD));
    }
  }

  String _getShortFileName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return 'File';
    final dotIndex = fileName.lastIndexOf('.');
    String name = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    String ext = dotIndex != -1 ? fileName.substring(dotIndex) : '';
    if (name.length > 8) name = '${name.substring(0, 5)}...';
    return '$name$ext';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (task.attachments.isEmpty) {
      return Row(
        children: [
          Icon(Icons.attachment_rounded, size: 18, color: theme.hintColor),
          const SizedBox(width: 6),
          Text(
            'No attachments',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: task.attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final att = task.attachments[index];
          final hint = provider.getFileType(att.fileName);
          final style = _styleFor(hint);
          final isImage = hint == 'image';
          final shortName = _getShortFileName(att.fileName);

          return GestureDetector(
            onTap: () =>
                _openAttachment(context, att, hint),
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isImage
                        ? Image.network(
                            att.url ?? '',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _iconTile(style, 50),
                          )
                        : _iconTile(style, 45),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconTile(_FileTypeStyle style, double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.08),
      ),
      child: Image.asset(style.assetPath, fit: BoxFit.contain),
    );
  }

  void _openAttachment(
      BuildContext context, TaskAttachmentModel att, String hint) {
    final url = att.url ?? '';
    final name = att.fileName ?? '';

    switch (hint) {
      case 'image':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => NetworkImageViewerScreen(url: url, fileName: name),
        ));
        break;
      case 'pdf':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: url, fileName: name),
        ));
        break;
      default:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GoogleDocsViewerScreen(fileUrl: url, fileName: name),
        ));
    }
  }
}

class _FileTypeStyle {
  final String assetPath;
  final Color color;
  const _FileTypeStyle(this.assetPath, this.color);
}


