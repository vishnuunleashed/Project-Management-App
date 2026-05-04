import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class TicketSummaryResponseModel extends BaseResponseModel {
  List<TicketSummaryModel> resultObject = [];

  TicketSummaryResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => TicketSummaryModel.fromJson(e))
        .toList();
  }
}
class TicketSummaryModel {
  int id = 0;
  String? ticketno;
  String? clientname;

  String? ticketdate;
  String? targetclosuredate;
  String? actualclosuredate;

  List<TicketStatusSummaryModel> summaryjson = [];

  TicketSummaryModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    ticketno = BaseJsonParser.goodString(json, 'ticketno');
    clientname = BaseJsonParser.goodString(json, 'clientname');

    ticketdate = BaseJsonParser.goodString(json, 'ticketdate');
    targetclosuredate =
        BaseJsonParser.goodString(json, 'targetclosuredate');
    actualclosuredate =
        BaseJsonParser.goodString(json, 'actualclosuredate');

    summaryjson = BaseJsonParser.goodList(json, 'summaryjson')
        .map((e) => TicketStatusSummaryModel.fromJson(e))
        .toList();
  }
}

class TicketStatusSummaryModel {
  int delayedcount = 0;
  int pendingcount = 0;
  int closedcount = 0;
  int totalcount = 0;

  TicketStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    delayedcount = BaseJsonParser.goodInt(json, 'delayedcount') ?? 0;
    pendingcount = BaseJsonParser.goodInt(json, 'pendingcount') ?? 0;
    closedcount = BaseJsonParser.goodInt(json, 'closedcount') ?? 0;
    totalcount = BaseJsonParser.goodInt(json, 'totalcount') ?? 0;
  }
}
