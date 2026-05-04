import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';

abstract class CloseObservationRepository extends BaseRepository {

  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void fetchObservationDetails(
      {required int observationId,
        required Function(List<ObservationDetailModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> fetchAttachmentsDetail({
    required List<AttachedDoc> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) ;

  void closeObservationSave(
      {
        required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> fetchActivityGroups({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure
  });

  Future<void> updateActivityStatus({
    required int observationId,
    required int? activityGroupId,
    required int? sourceOfErrorId,
    required int prevLogId,
    required int ownerId,
    required String remarks,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure});
}