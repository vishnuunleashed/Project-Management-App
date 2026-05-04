import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_location/geo_location.dart';
import 'package:interior_design/data/model/response/project_location/user_status.dart';
import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';

abstract class ProjectLocationRepository extends BaseRepository{
  void captureGeoLocation(
      {required LocationParams params,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure});
  void signInToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure});
  void signOutToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure});
  void getUserSignInStatus(
  { required int projectId,
   required Function(bool) onRequestSuccess,
    required Function(AppException) onRequestFailure});

  Future<void> getGeoCoordinatedByProject(
      { required Function(List<ProjectGeoResultObjectModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required int projectId});
}