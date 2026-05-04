import 'package:flutter/material.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';

class DccFileTile extends StatelessWidget {
  final DccFileModel file;
  final VoidCallback onTap;
  final bool isDownloading;
  final double downloadProgress;
  final String? locationPath;

  const DccFileTile({
    super.key,
    required this.file,
    required this.onTap,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.locationPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: _getFileColor(file.fileType).withOpacity(0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE8EDF2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildFileIcon(isDark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.filename,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,

                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (locationPath != null) ...[
                      const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatFileSize(file.fileSize??0),
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w300
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          file.lastModDateFormatted,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w300
                          ),
                        ),
                      ],
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: downloadProgress,
                          minHeight: 3,
                          backgroundColor: theme.dividerColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(_getFileColor(file.fileType)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSyncIcon(theme),
            ],
          ),
        ),
      ),
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
  }

  Widget _buildFileIcon(bool isDark) {
    final color = _getFileColor(file.fileType);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(child: _getFileTypeWidget(file.fileType, color)),
    );
  }

  Widget _getFileTypeWidget(DccFileType type, Color color) {
    switch (type) {
      case DccFileType.pdf:
        return Icon(Icons.picture_as_pdf_rounded, color: color, size: 22);
      case DccFileType.image:
        return Icon(Icons.image_rounded, color: color, size: 22);
      case DccFileType.word:
        return Text('W', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18));
      case DccFileType.excel:
        return Text('X', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18));
      case DccFileType.powerpoint:
        return Text('P', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18));
      case DccFileType.autocad:
        return Icon(Icons.architecture_rounded, color: color, size: 22);
      case DccFileType.other:
        return Icon(Icons.insert_drive_file_rounded, color: color, size: 22);
    }
  }

  Widget _buildSyncIcon(ThemeData theme) {
    if (isDownloading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: downloadProgress > 0 ? downloadProgress : null,
          valueColor: AlwaysStoppedAnimation<Color>(_getFileColor(file.fileType)),
        ),
      );
    }
    if (file.isDownloaded) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF4CAF50), size: 16),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(Icons.cloud_download_outlined, color: theme.iconTheme.color?.withOpacity(0.35), size: 16),
    );
  }

  static Color _getFileColor(DccFileType type) {
    switch (type) {
      case DccFileType.pdf: return const Color(0xFFE53935);
      case DccFileType.image: return const Color(0xFF43A047);
      case DccFileType.word: return const Color(0xFF1565C0);
      case DccFileType.excel: return const Color(0xFF2E7D32);
      case DccFileType.powerpoint: return const Color(0xFFEF6C00);
      case DccFileType.autocad: return const Color(0xFF6A1B9A);
      case DccFileType.other: return const Color(0xFF546E7A);
    }
  }
}
