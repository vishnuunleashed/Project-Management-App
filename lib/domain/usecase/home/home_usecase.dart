/*------------------------------------------------------------------------------
AUTHOR		    :Aswani Mohan
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/home/count_update_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/home/notification_count_model.dart';
import 'package:interior_design/data/remote/repository/home/home_repository_impl.dart';
import 'package:interior_design/domain/repository/home/home_repository.dart';

class HomeUseCase {
  factory HomeUseCase() => _instance;
  static final HomeUseCase _instance = HomeUseCase._internal();
  HomeUseCase._internal();

  void fetchProjectList({
    required Function(HomeDashboardWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    HomeRepositoryImpl().fetchProjectList(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void fetchPendingCount({
    required List<int> projectIds,
    required Function(List<ProjectStats>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    HomeRepositoryImpl().fetchPendingCount(
        projectIds: projectIds,
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }
  void fetchNotificationCountList({
    required Function(List<NotifyCountDTO>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    HomeRepositoryImpl().fetchNotificationCountList(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }
}
