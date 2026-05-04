
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class AttachmentResponseModel extends BaseResponseModel{
  List<AttachmentModel> attachmentUrl = [];
  AttachmentResponseModel.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    attachmentUrl = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => AttachmentModel.fromJson(e))
        .toList();
  }

}

class AttachmentModel{
  String? key;
  String url = '';
  AttachmentModel(
  {this.key,
  required this.url}
      );

  AttachmentModel.fromJson(Map<String,dynamic> json){
    key = BaseJsonParser.goodString(json, 'key');
    url = BaseJsonParser.goodString(json, 'url')??"";
  }

}