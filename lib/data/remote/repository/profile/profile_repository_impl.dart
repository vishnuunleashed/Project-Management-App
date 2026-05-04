import 'package:base/data_export.dart';
import 'package:interior_design/domain/repository/profile/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  @override
  Future<void> changePassword(
      {required String oldPassword,
      required String newPassword,
      required Function() onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    final Map<String, dynamic> rawData = {};
    final String urlExtension = 'ChangePassword/saveorupdate';
    rawData['oldPassword'] = oldPassword;
    rawData['newPassword'] = newPassword;
    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (response) {
          if (response['statusCode'] == 0) {
            onRequestFailure(
                AppException(response['resultObject'][0]['message']));
          } else {
            onRequestSuccess();
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> forgotPassword(
      {required String usernameOrEmail,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async{

    final Map<String, dynamic> rawData = {};
    final String urlExtension = 'Authentication/forgotPassword';
    rawData['identifier'] = usernameOrEmail;
    rawData['clientId'] = Connections().clientId;

    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (response) {
          if (response['statusCode'] == 0) {
            onRequestFailure(
                AppException(response['statusMessage']));
          } else {
            onRequestSuccess();
          }
        },
        onRequestFailure: onRequestFailure);

  }
}
