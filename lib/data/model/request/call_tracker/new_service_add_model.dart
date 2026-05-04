import 'package:base/data/models/response/image_upload_response.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';

class TicketModel {
  int id;
  String client;
  String sitename;
  String building;
  String floor;
  String address;
  String description;
  int categoryid;
  int priorityid;
  String? targetclosuredate;
  int? assigneduserid;
  int? servicereportuserid;
  String? lastmoddate;
  String? emailId;
  String? phoneNo;
  List<ServiceTaskModel> serviceTasks;
  List<UploadResponse> attachments = [];
  String cityName;
  String notifyClientYN;
  TicketModel({
    this.id = 0,
    required this.client,
    required this.sitename,
    required this.building,
    required this.floor,
    required this.address,
    required this.description,
    required this.categoryid,
    required this.priorityid,
    this.targetclosuredate,
    this.assigneduserid,
    this.servicereportuserid,
    this.lastmoddate,
    required this.serviceTasks,
    required this.cityName,
    this.emailId,
    this.phoneNo,
    this.notifyClientYN = "N"
  });


  @override
  String toString() {
    return '''
TicketModel(
  id: $id,
  client: $client,
  sitename: $sitename,
  building: $building,
  floor: $floor,
  address: $address,
  description: $description,
  categoryid: $categoryid,
  priorityid: $priorityid,
  targetclosuredate: ${targetclosuredate},
  assigneduserid: $assigneduserid,
  servicereportuserid: $servicereportuserid,
  lastmoddate: ${lastmoddate ?? 'null'}
)
''';
  }

}
