import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  bool get _isNetwork =>
      widget.url.startsWith('http://') || widget.url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isReady)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          _isNetwork
              ? SfPdfViewer.network(
                  widget.url,
                  controller: _pdfViewerController,
                  onDocumentLoaded: _onLoaded,
                  onPageChanged: _onPageChanged,
                  onDocumentLoadFailed: _onFailed,
                )
              : SfPdfViewer.file(
                  File(widget.url),
                  controller: _pdfViewerController,
                  onDocumentLoaded: _onLoaded,
                  onPageChanged: _onPageChanged,
                  onDocumentLoadFailed: _onFailed,
                ),
          if (!_isReady) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _onLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
      _isReady = true;
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() => _currentPage = details.newPageNumber - 1);
  }

  void _onFailed(PdfDocumentLoadFailedDetails details) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load PDF: ${details.error}')),
    );
  }
}
