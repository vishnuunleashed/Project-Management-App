class ProjectApprovalModel {
  int? rowid;
  int? projectid;
  String? status;
  String? remarks;
  String lastModDate;
  double? qty;

  ProjectApprovalModel({
    this.rowid,
    this.projectid,
    this.status,
    this.remarks,
    this.qty,
    required this.lastModDate,
  });



}