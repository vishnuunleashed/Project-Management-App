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
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/home/count_update_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';

import '../../../data/model/response/home/notification_count_model.dart' show NotifyCountDTO;

abstract class HomeRepository extends BaseRepository {
  void fetchProjectList({
    required Function(HomeDashboardWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });
  Future<void> fetchPendingCount({
    required List<int> projectIds,
    required Function(List<ProjectStats>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });
  Future<void> fetchAttachmentsDetail({
    required List<AttachedDoc> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> fetchNotificationCountList({
    required Function(List<NotifyCountDTO>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<int> fetchNotificationCountListRaw();
}