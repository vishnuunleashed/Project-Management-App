import 'package:base/data_export.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/remote/repository/close_observation/close_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';

class MyClosedObservationUseCase {
  factory MyClosedObservationUseCase() => _instance;
  static final MyClosedObservationUseCase _instance = MyClosedObservationUseCase._internal();
  MyClosedObservationUseCase._internal();


  //For fetching observation details
  void fetchObservationDetails(
      {required int observationId,
      required Function(List<ObservationDetailModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    CloseObservationRepositoryImpl().fetchObservationDetails(
        observationId: observationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For fetching status types
  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    CloseObservationRepositoryImpl().fetchStatusTypes(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  Future<void> fetchAttachmentsDetail(
      {required List<AttachedDoc> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    CloseObservationRepositoryImpl().fetchAttachmentsDetail(
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchObservationList(
      {String? flag,
        String? status,
        String? logStatus,
        required int start,
        required int limit,
        required int projectId,
        required String dateFrom,
        required String dateTo,
        required bool showAllObs,
        required bool obsViewOtherTransactionYN,
        required Function(List<ObservationDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required String points,
        required String transNo,
        int? observerId}) async {
    ProjectDetailsRepositoryImpl().fetchObservationList(
      flag: flag,
        status: status,
        logStatus: logStatus,
        projectId: projectId,
        start: start,
        limit: limit,
        dateFrom: dateFrom,
        dateTo: dateTo,
        showAllObs: showAllObs,
        transNo: transNo,
        points: points,
        observerId: observerId,
        delayedYN: "None",
        userId: 0,
        obsViewOtherTransactionYN : obsViewOtherTransactionYN,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

}
