
import 'package:base/data_export.dart';


class UploadResponseModel extends BaseResponseModel{

  List<UploadResponse>? uploadResponse;

  UploadResponseModel({this.uploadResponse});

  UploadResponseModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    if (json['resultObject'] != null) {
      uploadResponse = <UploadResponse>[];
      json['resultObject'].forEach((v) {
        uploadResponse!.add(UploadResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['statusMessage'] = statusMessage;
    if (uploadResponse != null) {
      data['resultObject'] = uploadResponse!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UploadResponse {
  String? message;
  String? url;
  String? filename;
  String? physicalfilename;
  String? serialno;

  UploadResponse({this.message, this.url, this.filename, this.serialno,this.physicalfilename});

  UploadResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    url = json['url'];
    filename = json['filename'];
    serialno = json['serialno'];
    physicalfilename = json['physicalfilename'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['url'] = url;
    data['filename'] = filename;
    data['physicalfilename'] = physicalfilename;
    data['serialno'] = serialno;
    return data;
  }
}
