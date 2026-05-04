import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/notification_history/notification_history_impl.dart';
import 'package:interior_design/data/remote/repository/project_schedule/project_schedule_impl.dart';

class NotificationHistoryUseCase{

  Future<void> fetchNotificationHistoryList({
    required int start,
    required int limit,
    required Function(List<NotificationList>) onRequestSuccess,
    required Function(AppException) onRequestFailure})async{
    NotificationHistoryRepositoryImpl().fetchNotificationHistoryList(
        start: start,
        limit: limit,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  updateReadStatus({
    required int notificationId,
    required Function(int) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }){
    CloseSupportRequestRepositoryImpl().updateNotificationStatus(
      notificationId: notificationId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure
    );
  }



}