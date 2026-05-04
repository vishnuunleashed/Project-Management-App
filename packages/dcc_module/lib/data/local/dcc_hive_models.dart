import 'package:hive/hive.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';

// ╔═══════════════════════════════════════════════════════════════════╗
// ║              DCC MODULE HIVE TYPE REGISTRY                        ║
// ║                                                                   ║
// ║  TypeID 110: DccFolderHive                                        ║
// ║  TypeID 111: DccFileHive                                          ║
// ║  TypeID 112: DccProjectHive                                       ║
// ║                                                                   ║
// ║  (Using IDs in the 100+ range to avoid collisions with main app)  ║
// ╚═══════════════════════════════════════════════════════════════════╝

@HiveType(typeId: 110)
class DccFolderHive extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? parentId;

  @HiveField(3)
  DateTime? createdOn;

  @HiveField(4)
  bool isPublic;

  @HiveField(5)
  bool isOwner;

  @HiveField(6)
  bool hasPermission;

  @HiveField(7)
  bool canDownload;

  @HiveField(8)
  bool canEdit;

  @HiveField(9)
  bool canDelete;

  @HiveField(10)
  bool isMappedRoot;

  @HiveField(11)
  bool isMappedFolder;

  @HiveField(12)
  bool canRename;

  @HiveField(13)
  bool canCut;

  @HiveField(14)
  bool canCopy;

  @HiveField(15)
  bool canCreate;

  DccFolderHive({
    required this.id,
    required this.name,
    this.parentId,
    this.createdOn,
    this.isPublic = false,
    this.isOwner = false,
    this.hasPermission = false,
    this.isMappedRoot = false,
    this.isMappedFolder = false,
    this.canDownload = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canRename = false,
    this.canCut = false,
    this.canCopy = false,
    this.canCreate = false,
  });

  factory DccFolderHive.fromModel(DccFolderModel model) => DccFolderHive(
        id: model.id,
        name: model.name,
        parentId: model.parentId,
        createdOn: model.createdOn,
        isPublic: model.isPublic,
        isOwner: model.isOwner,
        hasPermission: model.hasPermission,
        isMappedRoot: model.isMappedRoot,
        isMappedFolder: model.isMappedFolder,
        canDownload: model.canDownload,
        canEdit: model.canEdit,
        canDelete: model.canDelete,
        canRename: model.canRename,
        canCut: model.canCut,
        canCopy: model.canCopy,
        canCreate: model.canCreate,
      );

  DccFolderModel toModel() => DccFolderModel(
        id: id,
        name: name,
        parentId: parentId,
        createdOn: createdOn,
        isPublic: isPublic,
        isOwner: isOwner,
        hasPermission: hasPermission,
        isMappedRoot: isMappedRoot,
        isMappedFolder: isMappedFolder,
        canDownload: canDownload,
        canEdit: canEdit,
        canDelete: canDelete,
        canRename: canRename,
        canCut: canCut,
        canCopy: canCopy,
        canCreate: canCreate,
      );
}

@HiveType(typeId: 111)
class DccFileHive extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String filename;

  @HiveField(2)
  String fileextension;

  @HiveField(3)
  int folderid;

  @HiveField(4)
  DateTime? lastmoddate;

  @HiveField(5)
  String physicalFileUrl;

  @HiveField(6)
  String? localPath;

  @HiveField(7)
  bool isDownloaded;

  @HiveField(8)
  int fileSize;

  @HiveField(9)
  int currentversionno;

  DccFileHive({
    required this.id,
    required this.filename,
    required this.fileextension,
    required this.folderid,
    required this.currentversionno,
    this.lastmoddate,
    this.physicalFileUrl = '',
    this.localPath,
    this.isDownloaded = false,
    this.fileSize = 0,
  });

  factory DccFileHive.fromModel(DccFileModel model) => DccFileHive(
        id: model.id,
        filename: model.filename,
        fileextension: model.fileextension,
        folderid: model.folderid,
        currentversionno: model.currentversionno,
        lastmoddate: model.lastmoddate,
        physicalFileUrl: model.physicalFileUrl,
        localPath: model.localPath,
        isDownloaded: model.isDownloaded,
        fileSize: model.fileSize,
      );

  DccFileModel toModel() => DccFileModel(
        id: id,
        filename: filename,
        fileextension: fileextension,
        folderid: folderid,
        currentversionno: currentversionno,
        lastmoddate: lastmoddate,
        physicalFileUrl: physicalFileUrl,
        localPath: (localPath == null || localPath!.isEmpty) ? null : localPath,
        isDownloaded: isDownloaded,
        fileSize: fileSize,
      );
}

// ──────────────────────────────────────────────────────────
// Manual Adapters (No build_runner required)
// ──────────────────────────────────────────────────────────

class DccFolderHiveAdapter extends TypeAdapter<DccFolderHive> {
  @override
  final int typeId = 110;

  @override
  DccFolderHive read(BinaryReader reader) {
    final id = reader.readInt();
    final name = reader.readString();
    final pId = reader.readInt();
    final createdOn = reader.read() as DateTime?;
    
    // Read new fields
    final isPublic = reader.readBool();
    final isOwner = reader.readBool();
    final hasPermission = reader.readBool();
    final canDownload = reader.readBool();
    final canEdit = reader.readBool();
    final canDelete = reader.readBool();

    bool isMappedRoot = false;
    bool isMappedFolder = false;
    bool canRename = false;
    bool canCut = false;
    bool canCopy = false;
    bool canCreate = false;

    if (reader.availableBytes > 0) {
      try {
        isMappedRoot = reader.readBool();
        isMappedFolder = reader.readBool();
        canRename = reader.readBool();
        canCut = reader.readBool();
        canCopy = reader.readBool();
        canCreate = reader.readBool();
      } catch (_) {}
    }

    return DccFolderHive(
      id: id,
      name: name,
      parentId: pId == -1 ? null : pId,
      createdOn: createdOn,
      isPublic: isPublic,
      isOwner: isOwner,
      hasPermission: hasPermission,
      isMappedRoot: isMappedRoot,
      isMappedFolder: isMappedFolder,
      canDownload: canDownload,
      canEdit: canEdit,
      canDelete: canDelete,
      canRename: canRename,
      canCut: canCut,
      canCopy: canCopy,
      canCreate: canCreate,
    );
  }

  @override
  void write(BinaryWriter writer, DccFolderHive obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.parentId ?? -1);
    writer.write(obj.createdOn);
    
    // Write new fields
    writer.writeBool(obj.isPublic);
    writer.writeBool(obj.isOwner);
    writer.writeBool(obj.hasPermission);
    writer.writeBool(obj.canDownload);
    writer.writeBool(obj.canEdit);
    writer.writeBool(obj.canDelete);
    
    // Write mapped and permission fields
    writer.writeBool(obj.isMappedRoot);
    writer.writeBool(obj.isMappedFolder);
    writer.writeBool(obj.canRename);
    writer.writeBool(obj.canCut);
    writer.writeBool(obj.canCopy);
    writer.writeBool(obj.canCreate);
  }
}

class DccFileHiveAdapter extends TypeAdapter<DccFileHive> {
  @override
  final int typeId = 111;

  @override
  DccFileHive read(BinaryReader reader) {
    final file = DccFileHive(
      id: reader.readInt(),
      filename: reader.readString(),
      fileextension: reader.readString(),
      folderid: reader.readInt(),
      lastmoddate: reader.read() as DateTime?,
      physicalFileUrl: reader.readString(),
      localPath: reader.readString(),
      isDownloaded: reader.readBool(),
      fileSize: reader.readInt(),
      currentversionno: reader.readInt(),
    );
    // Convert empty string back to null for localPath
    if (file.localPath == '') file.localPath = null;
    return file;
  }

  @override
  void write(BinaryWriter writer, DccFileHive obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.filename);
    writer.writeString(obj.fileextension);
    writer.writeInt(obj.folderid);
    writer.write(obj.lastmoddate);
    writer.writeString(obj.physicalFileUrl);
    writer.writeString(obj.localPath ?? '');
    writer.writeBool(obj.isDownloaded);
    writer.writeInt(obj.fileSize);
    writer.writeInt(obj.currentversionno);
  }
}
//
// // ──────────────────────────────────────────────────────────
// // DccProjectHive — Offline Project List Entity
// // ──────────────────────────────────────────────────────────
// //
// @HiveType(typeId: 112)
// class DccProjectHive extends HiveObject {
//   @HiveField(0)
//   int projectId;
//
//   @HiveField(1)
//   String projectName;
//
//   @HiveField(2)
//   String? location;
//
//   @HiveField(3)
//   DateTime? endDate;
//
//   @HiveField(4)
//   int? rootFolderId;
//
//   DccProjectHive({
//     required this.projectId,
//     required this.projectName,
//     this.location,
//     this.endDate,
//     this.rootFolderId,
//   });
//
//   factory DccProjectHive.fromModel(DccProjectModel model) => DccProjectHive(
//         projectId: model.projectId ?? 0,
//         projectName: model.projectName ?? '',
//         location: model.location,
//         endDate: model.endDate,
//         rootFolderId: model.rootFolderId,
//       );
//
//   DccProjectModel toModel() => DccProjectModel(
//         projectId: projectId,
//         projectName: projectName,
//         location: location,
//         endDate: endDate,
//         rootFolderId: rootFolderId,
//       );
// }
//
// class DccProjectHiveAdapter extends TypeAdapter<DccProjectHive> {
//   @override
//   final int typeId = 112;
//
//   @override
//   DccProjectHive read(BinaryReader reader) {
//     return DccProjectHive(
//       projectId: reader.readInt(),
//       projectName: reader.readString(),
//       location: reader.readString(),
//       endDate: reader.read() as DateTime?,
//       rootFolderId: reader.readInt(),
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, DccProjectHive obj) {
//     writer.writeInt(obj.projectId);
//     writer.writeString(obj.projectName);
//     writer.writeString(obj.location ?? '');
//     writer.write(obj.endDate);
//     writer.writeInt(obj.rootFolderId ?? -1);
//   }
// }
