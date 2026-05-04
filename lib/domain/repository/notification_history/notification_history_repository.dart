import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';

abstract class NotificationHistoryRepository extends BaseRepository{
  Future<void> fetchNotificationHistoryList({
    required int start,
    required int limit,
    required Function(List<NotificationList>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
});
}