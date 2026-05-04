
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class NotifyCountWrapper extends BaseResponseModel{
  List<NotifyCountDTO> resultObject = [];

  NotifyCountWrapper.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject').map((e) => NotifyCountDTO.fromJson(e)).toList();
  }
}

class NotifyCountDTO {
  final int userid;
  final String clientid;
  final int unreadcount;


  NotifyCountDTO({
    required this.clientid,
    required this.userid,
    required this.unreadcount,
  });

  factory NotifyCountDTO.fromJson(Map<String, dynamic> json) {
    return NotifyCountDTO(
      userid: BaseJsonParser.goodInt(json, 'userid')??0,
      clientid:BaseJsonParser.goodString(json, 'clientid')??"",
      unreadcount: BaseJsonParser.goodInt(json, 'unreadcount')??0,
    );
  }
}