import 'dart:io';
import 'package:flutter/material.dart';

class DccImageViewer extends StatelessWidget {
  final String urlOrPath;
  final String fileName;

  const DccImageViewer({
    super.key,
    required this.urlOrPath,
    required this.fileName,
  });

  bool get _isNetwork =>
      urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 6.0,
          child: _isNetwork
              ? Image.network(
                  urlOrPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, _) => _buildError(theme),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                )
              : Image.file(
                  File(urlOrPath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, _) => _buildError(theme),
                ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
        const SizedBox(height: 12),
        const Text('Cannot load image', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
