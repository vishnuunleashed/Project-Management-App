import 'package:hive/hive.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';

import 'dcc_project_model.dart';

// ╔════════════════════════════════════════════════════════════════════╗
// ║              MAIN APP HIVE TYPE REGISTRY                          ║
// ║                                                                    ║
// ║  TypeID 113: HomeProjectListModel                                  ║
// ║                                                                    ║
// ║  Persisted Fields: projectId, project, projectLocation,            ║
// ║                    projectEndDate, rootFolderId                     ║
// ╚════════════════════════════════════════════════════════════════════╝

@HiveType(typeId: 112)
class DccProjectHive extends HiveObject {
  @HiveField(0)
  int projectId;

  @HiveField(1)
  String projectName;

  @HiveField(2)
  String? location;

  @HiveField(3)
  DateTime? endDate;

  @HiveField(4)
  int? rootFolderId;

  DccProjectHive({
    required this.projectId,
    required this.projectName,
    this.location,
    this.endDate,
    this.rootFolderId,
  });

  factory DccProjectHive.fromModel(DccProjectModel model) => DccProjectHive(
    projectId: model.projectId ?? 0,
    projectName: model.projectName ?? '',
    location: model.location,
    endDate: model.endDate,
    rootFolderId: model.rootFolderId,
  );

  DccProjectModel toModel() => DccProjectModel(
    projectId: projectId,
    projectName: projectName,
    location: location,
    endDate: endDate,
    rootFolderId: rootFolderId,
  );
}

class DccProjectHiveAdapter extends TypeAdapter<DccProjectHive> {
  @override
  final int typeId = 112;

  @override
  DccProjectHive read(BinaryReader reader) {
    return DccProjectHive(
      projectId: reader.readInt(),
      projectName: reader.readString(),
      location: reader.readString(),
      endDate: reader.read() as DateTime?,
      rootFolderId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DccProjectHive obj) {
    writer.writeInt(obj.projectId);
    writer.writeString(obj.projectName);
    writer.writeString(obj.location ?? '');
    writer.write(obj.endDate);
    writer.writeInt(obj.rootFolderId ?? -1);
  }
}
