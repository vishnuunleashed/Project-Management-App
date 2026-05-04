import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class StatusColorResponseModel extends BaseResponseModel {
  List<StatusItem> statusList = [];

  StatusColorResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    final list = BaseJsonParser.goodList(json, 'resultObject');

    if (list.isNotEmpty) {
      final Map<String, dynamic> data = list.first;

      statusList = data.entries
          .map((e) => StatusItem.fromJson(e.key, e.value))
          .toList();
    }
  }
}

class StatusItem {
  String? name;
  String? color;
  String? background;

  StatusItem({this.name, this.color, this.background});

  factory StatusItem.fromJson(String key, Map<String, dynamic> json) {
    return StatusItem(
      name: key,
      color: json['color']?.toString(),
      background: json['background']?.toString(),
    );
  }
}