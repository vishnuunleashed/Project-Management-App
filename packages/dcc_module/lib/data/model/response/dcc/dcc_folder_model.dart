import 'package:dcc_module/core/dcc_json_parser.dart';

class DccFolderModel {
  final int id;
  final String name;
  final int? parentId;
  final DateTime? createdOn;
  final bool isPublic;
  final bool isOwner;
  final bool hasPermission;
  final bool isMappedRoot;
  final bool isMappedFolder;
  final bool canDownload;
  final bool canEdit;
  final bool canDelete;
  final bool canRename;
  final bool canCut;
  final bool canCopy;
  final bool canCreate;

  DccFolderModel({
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

  factory DccFolderModel.fromJson(Map<String, dynamic> json) {
    int? pId = DccJsonParser.goodInt(json, 'parentId') ?? DccJsonParser.goodInt(json, 'parentid');
    if (pId == 0) pId = null;

    return DccFolderModel(
      id: DccJsonParser.goodInt(json, 'id') ?? 0,
      name: DccJsonParser.goodString(json, 'name') ?? '',
      parentId: pId,
      createdOn: DccJsonParser.goodDateTime(json, 'createdon'),
      isPublic: DccJsonParser.goodBoolean(json, 'isPublic'),
      isOwner: DccJsonParser.goodBoolean(json, 'isOwner'),
      hasPermission: DccJsonParser.goodBoolean(json, 'hasPermission'),
      isMappedRoot: DccJsonParser.goodBoolean(json, 'isMappedRoot') || DccJsonParser.goodBoolean(json, 'ismappedroot'),
      isMappedFolder: DccJsonParser.goodBoolean(json, 'isMappedFolder') || DccJsonParser.goodBoolean(json, 'ismappedfolder'),
      canDownload: DccJsonParser.goodBoolean(json, 'canDownload') || DccJsonParser.goodBoolean(json, 'candownload'),
      canEdit: DccJsonParser.goodBoolean(json, 'canEdit') || DccJsonParser.goodBoolean(json, 'canedit'),
      canDelete: DccJsonParser.goodBoolean(json, 'canDelete') || DccJsonParser.goodBoolean(json, 'candelete'),
      canRename: DccJsonParser.goodBoolean(json, 'canRename') || DccJsonParser.goodBoolean(json, 'canrename'),
      canCut: DccJsonParser.goodBoolean(json, 'canCut') || DccJsonParser.goodBoolean(json, 'cancut'),
      canCopy: DccJsonParser.goodBoolean(json, 'canCopy') || DccJsonParser.goodBoolean(json, 'cancopy'),
      canCreate: DccJsonParser.goodBoolean(json, 'canCreate') || DccJsonParser.goodBoolean(json, 'cancreate'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parentid': parentId,
    'createdon': createdOn?.toIso8601String(),
    'isPublic': isPublic,
    'isOwner': isOwner,
    'hasPermission': hasPermission,
    'isMappedRoot': isMappedRoot,
    'isMappedFolder': isMappedFolder,
    'canDownload': canDownload,
    'canEdit': canEdit,
    'canDelete': canDelete,
    'canRename': canRename,
    'canCut': canCut,
    'canCopy': canCopy,
    'canCreate': canCreate,
  };
}
