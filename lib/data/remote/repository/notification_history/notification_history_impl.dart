import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';
import 'package:interior_design/domain/repository/notification_history/notification_history_repository.dart';

class NotificationHistoryRepositoryImpl extends NotificationHistoryRepository{
  @override
  Future<void> fetchNotificationHistoryList({
    required int start,
    required int limit,
    required Function(List<NotificationList>) onRequestSuccess,
    required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Notification/notificationHistory?";
    final Map<String, dynamic> rawData = {};
    rawData["limit"] = limit;
    rawData["start"] = start;
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result){
          NotificationModel response = NotificationModel.fromJson(result);
          if(response.statusCode == 1) {
            onRequestSuccess(response.jsonList);
          }
          else{
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

}