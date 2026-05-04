import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DccFileStorageService {
  final Dio _dio = Dio();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getDccFolderPath(int folderId) async {
    final path = await _localPath;
    final dccPath = '$path/dcc/$folderId';
    final directory = Directory(dccPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return dccPath;
  }

  Future<String> downloadFile({
    required String url,
    required int folderId,
    required int documentId,
    required String extension,
    Function(double)? onProgress,
  }) async {
    final folderPath = await getDccFolderPath(folderId);
    final fileName = '$documentId.${extension.replaceAll('.', '')}';
    final savePath = '$folderPath/$fileName';

    await _dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          onProgress?.call(received / total);
        }
      },
    );

    return savePath;
  }

  Future<bool> fileExists(String? path) async {
    if (path == null) return false;
    return File(path).exists();
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearDccCache() async {
    final path = await _localPath;
    final directory = Directory('$path/dcc');
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
