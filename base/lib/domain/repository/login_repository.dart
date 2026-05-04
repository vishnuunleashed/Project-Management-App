import 'package:base/data/models/login/login_model.dart';
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';

abstract class LoginRepository extends BaseRepository {
  void authenticate({
    required String username,
    required String password,
    required Function(LoginWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure});

  void authenticateAutoLogin(
      {required int userID,
        required String refreshToken,
        required Function(LoginWrapper) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});
}