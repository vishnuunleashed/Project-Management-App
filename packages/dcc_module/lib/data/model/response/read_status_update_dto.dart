
import 'dart:convert';

import 'DccBaseResponseModel.dart';



class ReadStatusResponseWrapper extends DccBaseResponseModel{
  List<ReadStatusDto> resultObject = [];

  ReadStatusResponseWrapper.fromJson(Map<String, dynamic> parsedJson)
      : super.fromJson(parsedJson) {
    if (parsedJson['resultObject'].isNotEmpty
        && parsedJson['resultObject'] != null) {
      resultObject = [];
      List<dynamic> responseList = jsonDecode(parsedJson['resultObject']);
      for (var mod in responseList) {
        resultObject.add(ReadStatusDto.fromJson(mod));

      }
    } else {
      resultObject = [];
    }
  }

}
class ReadStatusResultIdDto {
  final int id;

  ReadStatusResultIdDto({required this.id});

  factory ReadStatusResultIdDto.fromJson(Map<String, dynamic> json) {
    return ReadStatusResultIdDto(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class ReadStatusDto {
  final int transid;
  final int transtableid;
  final int notificationid;

  ReadStatusDto({
    required this.transid,
    required this.transtableid,
    required this.notificationid,
  });

  factory ReadStatusDto.fromJson(Map<String, dynamic> json) {
    return ReadStatusDto(
      transid: json['transid'],
      transtableid: json['transtableid'],
      notificationid: json['notificationid']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transid': transid,
      'transtableid': transtableid,
      'notificationid': notificationid,
    };
  }
}
