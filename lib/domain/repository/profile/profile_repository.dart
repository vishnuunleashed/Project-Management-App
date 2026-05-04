import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';

abstract class ProfileRepository extends BaseRepository {
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> forgotPassword({
    required String usernameOrEmail,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });
}
