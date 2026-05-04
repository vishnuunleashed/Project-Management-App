class ObservationRawDataModel {
  int observationid;
  int statusid;
  String statuscode;
  String remarks;
  int? prevlogid;
  int? ownerId;

  ObservationRawDataModel({
    required this.observationid,
    required this.statusid,
    required this.statuscode,
    required this.remarks,
    required this.prevlogid,
    this.ownerId,
  });


}