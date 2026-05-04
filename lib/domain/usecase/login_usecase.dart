import 'package:base/data/models/login/login_model.dart';
import 'package:base/data_export.dart';
import 'package:interior_design/data/remote/repository/login/login_repository_impl.dart';

class LoginUseCase {
  factory LoginUseCase() => _instance;
  static final LoginUseCase _instance = LoginUseCase._internal();
  LoginUseCase._internal();

  void authenticate(
      {required String username,
      required String password,
      required Function(LoginWrapper) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    LoginRepositoryImpl().authenticate(
        username: username,
        password: password,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void authenticateAutoLogin(
      {required int userID,
      required String refreshToken,
      required Function(LoginWrapper) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    LoginRepositoryImpl().authenticateAutoLogin(
        userID: userID,
        refreshToken: refreshToken,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}
