class TaskAgainstSupportListModel {
  int start;
  int limit;
  int projectId;
  int taskId;
  int materialItemId;
  String status;
  String action;
  String transNo;
  String dateFrom;
  String dateTo;
  bool isShowAllTaskSupport;
  bool isFromAdditionalMaterial;
  TaskAgainstSupportListModel(
      {required this.projectId,
      required this.taskId,
      required this.materialItemId,
      required this.status,
      required this.action,
      required this.transNo,
      required this.start,
      required this.limit,
      required this.isShowAllTaskSupport,
      required this.isFromAdditionalMaterial,
      required this.dateFrom,
      required this.dateTo});
}
