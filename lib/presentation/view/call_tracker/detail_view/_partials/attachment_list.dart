import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/pdf_viewer_screen.dart';
import 'google_docs_viewer_screen.dart';
import 'network_image_view_screen.dart';

class AttachmentList extends StatelessWidget {
  final List<TaskAttachmentModel> attachments;
  final void Function(int)? onRemove;

  const AttachmentList({super.key,
    required this.attachments,
    required this.onRemove,
  });

  static _FileTypeStyle _styleFor(String hint) {
    switch (hint) {
      case 'pdf':
        return const _FileTypeStyle(
            'assets/png/pdf.png', Color(0xFFE74C3C));

      case 'xls':
        return const _FileTypeStyle(
            'assets/png/excel.png', Color(0xFF27AE60));

      case 'doc':
        return const _FileTypeStyle(
            'assets/png/doc.png', Color(0xFF2980B9));

      case 'image':
        return const _FileTypeStyle(
            'assets/png/image.png', Color(0xFF6366F1));

      default:
        return const _FileTypeStyle(
            'assets/png/file.png', Color(0xFF8E44AD));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseStatelessConsumer<ServiceTasksProvider>(
      provider: serviceTasksProvider,
      builder: (context, provider, ref) {
        return Column(
          children: attachments.asMap().entries.map((entry) {
            final i = entry.key;
            final att = entry.value;

            // 🔥 Use provider function here
            final hint = provider.getFileType(att.fileName);
            final style = _styleFor(hint);

            final isImage = hint == 'image';

            return GestureDetector(
              onTap: () => _openAttachment(context, att, hint),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Thumbnail / Icon ─────────────────────────────
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11),
                      ),
                      child: isImage
                          ? Image.network(
                        att.url ?? '',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _iconTile(style),
                      )
                          : _iconTile(style),
                    ),

                    const SizedBox(width: 12),

                    // ── File name + type badge ───────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            att.fileName ?? 'Attachment',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: style.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hint.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: style.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Remove button ────────────────────────────────
                    Visibility(
                      visible: onRemove != null,
                      child: IconButton(
                        onPressed: () {
                          final router = GoRouter.of(context);
                          BaseDialog.show(
                            context: context,
                            title: "Confirm",
                            message: "Do you want to remove this attachment?",
                            actions: [
                              Row(
                                spacing: 4,
                                children: [
                                  Expanded(
                                    child: BaseElevatedButton(
                                      borderRadius: 24,
                                      backgroundColor: bayaInfraDisabledColor,
                                      onPressed: () => router.pop(),
                                      text : "Cancel",
                                    ),
                                  ),
                                  Expanded(
                                    child: BaseElevatedButton(
                                      borderRadius: 24,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        router.pop();
                                        onRemove!(i);
                                      },
                                      text: 'Remove',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
            },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        color: const Color(0xFFE74C3C),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _iconTile(_FileTypeStyle style) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.08),
      ),
      child: Image.asset(
        style.assetPath,
        fit: BoxFit.contain,
      ),
    );
  }

  void _openAttachment(
      BuildContext context,
      TaskAttachmentModel att,
      String hint,
      ) {
    final url = att.url ?? '';
    final name = att.fileName ?? '';

    switch (hint) {
      case 'image':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              NetworkImageViewerScreen(url: url, fileName: name),
        ));
        break;

      case 'pdf':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              PdfViewerScreen(url: url, fileName: name),
        ));
        break;

      default:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              GoogleDocsViewerScreen(fileUrl: url, fileName: name),
        ));
    }
  }
}

class _FileTypeStyle {
  final String assetPath;
  final Color color;

  const _FileTypeStyle(this.assetPath, this.color);
}