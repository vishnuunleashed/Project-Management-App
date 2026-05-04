
import 'package:base/data/services/utils/base_json_parser.dart';

class ScheduleProjectDetails {
  String? projectname;
  String? projectlocation;
  String? clientname;
  String? startdate;
  String? enddate;


  ScheduleProjectDetails.fromJson(Map<String, dynamic> json) {
      projectname= BaseJsonParser.goodString(json, 'projectname')??'';
      projectlocation=  BaseJsonParser.goodString(json, 'projectlocation')??'';
      clientname=  BaseJsonParser.goodString(json, 'clientname')??'';
      startdate=  BaseJsonParser.goodString(json, 'startdate')??'';
      enddate=  BaseJsonParser.goodString(json, 'enddate')??'';

  }
}
