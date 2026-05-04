// ─────────────────────────────────────────────────────────────────────────────
// Full-screen network image viewer
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class NetworkImageViewerScreen extends StatelessWidget {
  final String url;
  final String fileName;

  const NetworkImageViewerScreen({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 6.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_rounded,
                    color: theme.hintColor, size: 64),
                const SizedBox(height: 12),
                Text('Cannot load image',
                    style: TextStyle(color: theme.hintColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}