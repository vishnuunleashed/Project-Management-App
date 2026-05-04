import 'package:base/data/models/response/image_upload_response.dart';

class AddObservationRequest {
  final int optionId;
  final int projectId;
  final int ownerId;
  final String observationPoints;
  final String seriesNo;
  final bool isFromMOM;
  final int? actionItemId;
  final List<UploadResponse> imagesDtl;

  AddObservationRequest({
    required this.optionId,
    required this.projectId,
    required this.ownerId,
    required this.observationPoints,
    required this.seriesNo,
    required this.imagesDtl,
    this.isFromMOM = false,
    this.actionItemId
  });
}