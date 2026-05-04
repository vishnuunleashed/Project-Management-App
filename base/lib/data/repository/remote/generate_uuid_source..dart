
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/domain/repository/generate_uuid_repo.dart';

class GenerateUUIDRepositoryImpl extends GenerateUUIDRepository {

  @override
  void fetchUUID(
      {required Function(String) onSuccess,
      required Function(AppException) onFailure}) async {
    // int userId = await BasePrefs.getInt(BaseConstants.USERID_KEY);

    // String service = "getuuid";
    // performRequest(
    //     service: service,
    //     userid: userId,
    //     onRequestSuccess: (response) {
    //       onSuccess(response["uuid"]);
    //       BasePrefs.setString(BaseConstants.UUID_KEY, response["uuid"]);
    //     },
    //     onRequestFailure: (exception) {
    //       onFailure(exception);
    //     });
  }

  @override
  void clearUUID() {
    // BasePrefs.setString(BaseConstants.UUID_KEY, "");
  }
}
