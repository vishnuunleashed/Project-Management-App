import 'dart:convert';
import 'dart:io';
import 'package:dcc_module/data/local/dcc_hive_models.dart';
import 'package:hive/hive.dart';
import 'package:interior_design/data/local/hive/home_projectlist_model_adapter.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:path_provider/path_provider.dart';

import 'dcc_project_model.dart';

class DccHiveDebugUtility {
  static const String folderBoxName = 'dcc_folders';
  static const String fileBoxName = 'dcc_files';
  static const String projectBoxName = 'dcc_projects';

  /// Exports all DCC Hive data to a JSON file and returns the file path.
  static Future<String?> exportDccDataToJSON() async {
    try {
      final folderBox = await Hive.openBox<DccFolderHive>(folderBoxName);
      final fileBox = await Hive.openBox<DccFileHive>(fileBoxName);
      final projectBox = await Hive.openBox<DccProjectHive>(projectBoxName);

      final Map<String, dynamic> exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'dcc_folders': folderBox.values.map((v) => v.toModel().toJson()).toList(),
        'dcc_files': fileBox.values.map((v) => v.toModel().toJson()).toList(),
        'dcc_projects': projectBox.values.map((v) => v.toModel().toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'dcc_hive_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      print('DCC Hive Export Error: $e');
      return null;
    }
  }
}
