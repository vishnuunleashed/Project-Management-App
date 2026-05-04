import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DccGoogleDocsViewer extends StatefulWidget {
  final String fileName;
  final String fileUrl;

  const DccGoogleDocsViewer({
    super.key,
    required this.fileName,
    required this.fileUrl,
  });

  @override
  State<DccGoogleDocsViewer> createState() => _DccGoogleDocsViewerState();
}

class _DccGoogleDocsViewerState extends State<DccGoogleDocsViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  String get _viewerUrl {
    final encoded = Uri.encodeComponent(widget.fileUrl);
    return 'https://view.officeapps.live.com/op/view.aspx?src=$encoded';
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_viewerUrl));
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadRequest(Uri.parse(_viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller),

          if (_isLoading && !_hasError)
            const Center(child: CircularProgressIndicator()),

          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load document.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure the file URL is publicly accessible.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: _reload,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
