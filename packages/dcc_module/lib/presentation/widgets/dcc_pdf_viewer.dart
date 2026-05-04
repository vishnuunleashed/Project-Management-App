import 'dart:io';
import 'package:dcc_module/presentation/utility/dcc_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class DccPdfViewer extends StatefulWidget {
  final String urlOrPath;
  final String fileName;

  const DccPdfViewer({
    super.key,
    required this.urlOrPath,
    required this.fileName,
  });

  @override
  State<DccPdfViewer> createState() => _DccPdfViewerState();
}

class _DccPdfViewerState extends State<DccPdfViewer> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String? _localPath;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  bool get _isNetwork =>
      widget.urlOrPath.startsWith('http://') || widget.urlOrPath.startsWith('https://');

  @override
  void initState() {
    super.initState();
    if (_isNetwork) {
      _downloadFile();
    } else {
      _localPath = widget.urlOrPath;
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/${widget.fileName.replaceAll(' ', '_')}';
      
      await dio.download(
        widget.urlOrPath,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = count / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _localPath = savePath;
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        DccSnackBar().show(context: context, message: 'Failed to download PDF: $e');
      }
    }
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
      body: _isDownloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 16),
                  Text('Downloading PDF... ${( _downloadProgress * 100).toInt()}%'),
                ],
              ),
            )
          : _localPath == null
              ? const Center(child: Text('Could not load PDF'))
              : Stack(
                  children: [
                    PDFView(
                      filePath: _localPath!,
                      autoSpacing: true,
                      enableSwipe: true,
                      pageSnap: true,
                      swipeHorizontal: true,
                      nightMode: Theme.of(context).brightness == Brightness.dark,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 0;
                          _isReady = true;
                        });
                      },
                      onPageChanged: (page, total) {
                        setState(() {
                          _currentPage = page ?? 0;
                        });
                      },
                      onError: (error) {
                        DccSnackBar().show(context: context, message: 'Error loading PDF: $error');
                      },
                    ),
                    if (!_isReady) const Center(child: CircularProgressIndicator()),
                  ],
                ),
    );
  }
}
