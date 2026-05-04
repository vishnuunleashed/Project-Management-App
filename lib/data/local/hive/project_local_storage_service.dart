import 'package:hive/hive.dart';
import 'package:interior_design/data/local/hive/home_projectlist_model_adapter.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';

import 'dcc_project_model.dart';
import 'package:interior_design/utils/background_logger.dart';
class ProjectLocalStorageService {
  static const String _projectBoxName = 'dcc_projects';

  // ─── Project List ────────────────────────────────────────────

  Future<void> saveProjects(List<DccProjectModel> projects) async {
    final box = await Hive.openBox<DccProjectHive>(_projectBoxName);
    await box.clear();
    // Convert DccProjectModel to DccProjectHive for storage
    await box.addAll(projects.map((e) => DccProjectHive.fromModel(e)).toList());

  }

  Future<void> saveSingleProject(DccProjectModel project) async {
    final box = await Hive.openBox<DccProjectHive>(_projectBoxName);
    await box.put(project.projectId, DccProjectHive.fromModel(project));
    await BackgroundLogger.log('Projects ${project.projectName} ${project.projectId} ${project.rootFolderId} to Hive');
  }

  Future<List<DccProjectModel>> getProjects() async {
    final box = await Hive.openBox<DccProjectHive>(_projectBoxName);
    // Convert storage entity back to DccProjectModel for app use
    return box.values.map((e) => e.toModel()).toList();
  }

  Future<void> clearProjects() async {
    final box = await Hive.openBox<DccProjectHive>(_projectBoxName);
    await box.clear();
  }

  // ─── Root Folder ID Update ───────────────────────────────────
  // Updates the rootFolderId on the matching project in the Hive box.

  Future<void> updateProjectRootFolderId(int projectId, int rootFolderId) async {
    final box = await Hive.openBox<DccProjectHive>(_projectBoxName);
    final projects = box.values.toList();
    for (int i = 0; i < projects.length; i++) {
      if (projects[i].projectId == projectId) {
        projects[i].rootFolderId = rootFolderId;
        await box.putAt(i, projects[i]);
        break;
      }
    }
  }
}

