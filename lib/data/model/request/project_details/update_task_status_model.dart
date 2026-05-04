import 'package:base/data/models/response/image_upload_response.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';

class ProjectScheduleHdr {
  final int id;
  final int statusid;
  final int completionperc;
  final int taskuserid;
  final String plannedstartdate;
  final String plannedenddate;
  final String seriesNo;
  final List<UploadResponse> imagesDtl;
  final String lastmoddate;
  final List<CheckListModel> checkListData;

  ProjectScheduleHdr({
    required this.id,
    required this.statusid,
    required this.completionperc,
    required this.taskuserid,
    required this.plannedstartdate,
    required this.plannedenddate,
    required this.seriesNo,
    required this.imagesDtl,
    required this.lastmoddate,
    required this.checkListData
  });


}