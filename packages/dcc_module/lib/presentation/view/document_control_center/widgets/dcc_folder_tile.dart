import 'package:flutter/material.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
import 'dcc_folder_icon.dart';

class DccFolderTile extends StatelessWidget {
  final DccFolderModel folder;
  final VoidCallback onTap;
  final int subfolderCount;
  final int fileCount;
  final String? locationPath;

  const DccFolderTile({
    super.key,
    required this.folder,
    required this.onTap,
    this.subfolderCount = 0,
    this.fileCount = 0,
    this.locationPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine Folder Colors based on properties
    final Color bodyColor;
    final Color tabColor;

    if (folder.isMappedFolder) {
      // Mapped: Purple
      bodyColor = const Color(0xFF8B5CF6);
      tabColor = const Color(0xFF7C3AED);
    } else if (folder.isPublic) {
      // Public: Orange
      bodyColor = const Color(0xFFF59E0B);
      tabColor = const Color(0xFFD97706);
    } else if (folder.hasPermission) {
      // Permission: Green
      bodyColor = const Color(0xFF10B981);
      tabColor = const Color(0xFF059669);
    } else {
      // Default/Owner: Blue
      bodyColor = const Color(0xFF3B82F6);
      tabColor = const Color(0xFF2563EB);
    }

    // Build subtitle string based on counts
    String? subtitle;
    if (subfolderCount > 0 || fileCount > 0) {
      final List<String> parts = [];
      if (subfolderCount > 0) {
        parts.add('$subfolderCount folder${subfolderCount != 1 ? 's' : ''}');
      }
      if (fileCount > 0) {
        parts.add('$fileCount file${fileCount != 1 ? 's' : ''}');
      }
      subtitle = parts.join(' · ');
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: bodyColor.withOpacity(0.08),
        child: Card(
          elevation: 0.5,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                DccFolderIcon(
                  bodyColor: bodyColor,
                  tabColor: tabColor,
                  size: 38,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (locationPath != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          locationPath!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.textTheme.titleSmall?.color?.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.iconTheme.color?.withOpacity(0.3), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
