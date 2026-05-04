
import 'dart:io';

class FileUploadModel {
  String? filePhysicalName;
  String filename;
  String? fileExtension;
  String path;
  File file;

  FileUploadModel(
      {this.filePhysicalName,
      required this.filename,
      this.fileExtension,
      required this.path,
      required this.file});

  FileUploadModel copyWith(
      {String? filePhysicalName,
      String? filename,
      String? fileextension,
      String? path,
      File? file}) {
    return FileUploadModel(
        filePhysicalName: filePhysicalName ?? this.filePhysicalName,
        filename: filename ?? this.filename,
        fileExtension: fileextension ?? fileExtension,
        path: path ?? this.path,
        file: file ?? this.file);
  }
}
