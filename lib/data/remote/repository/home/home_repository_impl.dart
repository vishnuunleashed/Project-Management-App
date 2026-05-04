/*------------------------------------------------------------------------------
AUTHOR		    : Aswani Mohan
CREATED DATE	: 07/08/2025
PURPOSE		    : Fetch project list and user rights from dashboard API
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'dart:async';

import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/home/count_update_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/home/notification_count_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/repository/home/home_repository.dart';




class HomeRepositoryImpl extends HomeRepository {
  @override
  Future<void> fetchProjectList({
    required Function(HomeDashboardWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "Project/GetDashboard?";
    int userID = await BaseSecureStorage.getInt(BaseConstants.userID);
    final Map<String, dynamic> rawData = {};
    rawData["userID"] = "$userID";
    performGetRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          // Parse entire response into wrapper model
          HomeDashboardWrapper dashboardData = HomeDashboardWrapper.fromJson(response);

          onRequestSuccess(dashboardData);
        } catch (e) {
          onRequestFailure(
            AppException('Data parsing error: ${e.toString()}'),
          );
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> fetchPendingCount({
    required List<int> projectIds,
    required Function(List<ProjectStats>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {


    final Map<String, dynamic> rawData = {};

    for (int i = 0; i < projectIds.length; i++) {
      rawData['projectIds[$i]'] = projectIds[i];
    }

    final String urlExtension = "Project/GetDetailCount?";

    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        CountUpdateDto response = CountUpdateDto.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response.resultObject);
        }
        else{
          onRequestFailure(AppException(response.statusMessage??""));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<int> fetchNotificationCountListRaw() async {
    final completer = Completer<int>();

    performRequest(
      urlExtension: "Notification/NotificationCountList",
      rawData: {},
      onRequestSuccess: (response) {
        try {
          NotifyCountWrapper result = NotifyCountWrapper.fromJson(response);
          final count = result.resultObject.first.unreadcount;
          completer.complete(count);
        } catch (e) {
          completer.complete(0);
        }
      },
      onRequestFailure: (exception) {
        completer.complete(0);          //  Never crashes, defaults to 0
      },
    );

    return completer.future;
  }
 @override
  Future<void> fetchNotificationCountList({
    required Function(List<NotifyCountDTO>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {

    final String urlExtension = "Notification/NotificationCountList";

    performRequest(
      rawData: {},
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        NotifyCountWrapper response = NotifyCountWrapper.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response.resultObject);
        }
        else{
          onRequestFailure(AppException(response.statusMessage??""));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> fetchAttachmentsDetail({
    bool isProfilePic =false,
    required List<AttachedDoc> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    final List<String> fileNames = attachmentList
        .map((attachment) => attachment.attachmentphysicalname ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final Map<String, dynamic> rawData = {};

    // Option A: Multiple keys with same parameter name
    for (int i = 0; i < fileNames.length; i++) {
      rawData['keys[$i]'] = fileNames[i];
      rawData['IsProfilePic'] = isProfilePic;

    }

    final String urlExtension = "FileUpload/GetFiles?";

    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        AttachmentResponseModel response = AttachmentResponseModel.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response);
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }
}
