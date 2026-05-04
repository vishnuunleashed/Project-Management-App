import 'package:dcc_module/core/dcc_json_parser.dart';
import 'package:intl/intl.dart';

enum DccFileType { pdf, image, word, excel, powerpoint, autocad, other }

class DccFileModel {
  final int id;
  final String filename;
  final String fileextension;
  final int folderid;
  final int currentversionno;
  final DateTime? lastmoddate;
  final String physicalFileUrl;
  final String? localPath;
  final bool isDownloaded;
  final int fileSize;

  DccFileModel({
    required this.id,
    required this.currentversionno,
    required this.filename,
    required this.fileextension,
    required this.folderid,
    this.lastmoddate,
    this.physicalFileUrl = '',
    this.localPath,
    this.isDownloaded = false,
    this.fileSize = 0,
  });

  factory DccFileModel.fromJson(Map<String, dynamic> json) {
    return DccFileModel(
      id: DccJsonParser.goodInt(json, 'id') ?? 0,
      currentversionno: DccJsonParser.goodInt(json, 'currentversionno') ?? 0,
      filename: DccJsonParser.goodString(json, 'filename') ?? '',
      fileextension: DccJsonParser.goodString(json, 'fileextension') ?? '',
      folderid: DccJsonParser.goodInt(json, 'folderid') ?? 0,
      lastmoddate: DccJsonParser.goodDateTime(json, 'lastmoddate'),
      physicalFileUrl: DccJsonParser.goodString(json, 'physicalFileUrl') ??
          DccJsonParser.goodString(json, 'physicalfileurl') ??
          '',
      localPath: DccJsonParser.goodString(json, 'localPath'),
      isDownloaded: DccJsonParser.goodBoolean(json, 'isDownloaded'),
      fileSize: DccJsonParser.goodInt(json, 'filesize') ??0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'currentversionno': currentversionno,
    'filename': filename,
    'fileextension': fileextension,
    'folderid': folderid,
    'lastmoddate': lastmoddate?.toIso8601String(),
    'physicalFileUrl': physicalFileUrl,
    'localPath': localPath,
    'isDownloaded': isDownloaded,
    'fileSize': fileSize,
  };

  DccFileModel copyWith({
    String? localPath,
    bool? isDownloaded,
  }) {
    return DccFileModel(
      id: id,
      currentversionno: currentversionno,
      filename: filename,
      fileextension: fileextension,
      folderid: folderid,
      lastmoddate: lastmoddate,
      physicalFileUrl: physicalFileUrl,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      fileSize: fileSize,
    );
  }

  DccFileModel copyWithUrl(String url) {
    return DccFileModel(
      id: id,
      currentversionno: currentversionno,
      filename: filename,
      fileextension: fileextension,
      folderid: folderid,
      lastmoddate: lastmoddate,
      physicalFileUrl: url,
      localPath: localPath,
      isDownloaded: isDownloaded,
      fileSize: fileSize,
    );
  }

  DccFileType get fileType {
    final ext = fileextension.toLowerCase();
    if (ext.contains('pdf')) return DccFileType.pdf;
    if (ext.contains('jpg') || ext.contains('png') || ext.contains('jpeg')) {
      return DccFileType.image;
    }
    if (ext.contains('doc')) return DccFileType.word;
    if (ext.contains('xls') || ext.contains('csv')) return DccFileType.excel;
    if (ext.contains('ppt')) return DccFileType.powerpoint;
    if (ext.contains('dwg') || ext.contains('dxf')) return DccFileType.autocad;
    return DccFileType.other;
  }

  String get fileSizeFormatted {
    if (fileSize <= 0) return '0 KB';
    final kb = fileSize / 1024;
    if (kb >= 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(1)} KB';
  }

  String get lastModDateFormatted {
    if (lastmoddate == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(lastmoddate!);
  }
}
