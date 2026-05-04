
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';

abstract class GenerateUUIDRepository extends BaseRepository{

  void fetchUUID(
      {required Function(String) onSuccess,
      required Function(AppException) onFailure});
  void clearUUID();

}
