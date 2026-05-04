
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';


class Notification extends BaseRepository {
  static final Notification _instance = Notification._();

  Notification._();

  factory Notification() => _instance;

  getNotificationData(
      {required Function(NotificationModel response) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) async {

    int? userID = await BaseSecureStorage.getInt(BaseConstants.userID);
    String clientId = Connections().clientId;
    Map<String,dynamic> rawData= {
      "userId": userID,
      "clientId": clientId
    };

    String url = "Notification/pendingNotifications";

    performRequest(
      urlExtension: url,
      rawData: rawData,
      onRequestSuccess: (result) {
        NotificationModel response = NotificationModel.fromJson(result);
        if (response.statusCode == 1 && result.containsKey('resultObject')) {
          onRequestSuccess(response);
        } else {

          onRequestFailure(InvalidInputException(response.statusMessage));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

}
