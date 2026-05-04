import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_location/geo_location.dart';
import 'package:interior_design/data/model/response/project_location/user_status.dart';
import 'package:interior_design/domain/repository/project_location/project_location_repo.dart';

class LocationParams{
  int projectId;
  double latitude;
  double longitude;
  String allowedRadiusMeters;
  String geoTolerance;
  String projectName;
  String seriesNo;
  final List<UploadResponse> imagesDtl;

  LocationParams({
    required this.projectId,
     this.latitude = 0.0,
     this.longitude = 0.0,
     this.seriesNo='',
    required this.allowedRadiusMeters,
    required this.geoTolerance,
    this.imagesDtl  = const [],
    required this.projectName});

  LocationParams copyWith({
    int? projectId,
    double? latitude,
    double? longitude,
    String? allowedRadiusMeters,
    String? geoTolerance,
    String? projectName,
    String? seriesNo,
    List<UploadResponse>? imagesDtl,
  }) {
    return LocationParams(
      projectId: projectId ?? this.projectId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      geoTolerance: geoTolerance ?? this.geoTolerance,
      projectName: projectName ?? this.projectName,
      seriesNo: seriesNo ?? this.seriesNo,
      imagesDtl: imagesDtl ?? this.imagesDtl,
    );
  }
}
class ProjectLocationImpl extends ProjectLocationRepository{
  factory ProjectLocationImpl() => _instance;
  static final ProjectLocationImpl _instance = ProjectLocationImpl._internal();
  ProjectLocationImpl._internal();

  @override
  Future<void> captureGeoLocation(

      {required LocationParams params,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {

    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = params.projectId;
    rawData["latitude"] = params.latitude;
    rawData["longitude"] = params.longitude;
    rawData["allowedRadiusMeters"] = params.allowedRadiusMeters;
    rawData["geoTolerance"] = params.geoTolerance;
    rawData["projectName"] = params.projectName;

    const String urlExtension = "project/capturegeolocation";

    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          onRequestSuccess();
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }
  @override
  Future<void> signInToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {


    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = params.projectId;
    rawData["latitude"] = params.latitude;
    rawData["longitude"] = params.longitude;

    if(params.imagesDtl.isNotEmpty){
      rawData["docAttachments"] = [
        {
          "DocumentId": 7,
          "seriesno": params.seriesNo,
          "attachmentDtls": _buildAttachmentDtls(params.imagesDtl),
        }
      ];
    }
    const String urlExtension = "geofence/signin";

    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          if(result["statusCode"] == 0){
            onRequestFailure(UnNamedMessage(result["statusMessage"]));
          }else{
            onRequestSuccess(result["statusMessage"]);
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }

  List<Map<String, dynamic>> _buildAttachmentDtls(List<UploadResponse> imagesDtl) {
    return imagesDtl.map((img) => {
      "filename": img.filename ?? "",
      "physicalfilename": img.physicalfilename ?? "",
    }).toList();
  }
  @override
  Future<void> signOutToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {


    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = params.projectId;
    rawData["latitude"] = params.latitude;
    rawData["longitude"] = params.longitude;


    const String urlExtension = "geofence/signout";

    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          if(result["statusCode"] == 0){
            onRequestFailure(UnNamedMessage(result["statusMessage"]));
          }else{
            onRequestSuccess(result["statusMessage"]);
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }

  @override
  Future<void> getUserSignInStatus(
      { required Function(bool) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required int projectId}) async {


    const String urlExtension = "geofence/getusersigninstatus";

    performGetRequest(
        rawData: {"ProjectId":projectId},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          SignInStatusResponseModel signInStatusResponseModel = SignInStatusResponseModel.fromJson(result);
          if(signInStatusResponseModel.statusCode == 0){
            onRequestSuccess(false);
          }else{
            onRequestSuccess(true);
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }
  @override
  Future<void> getGeoCoordinatedByProject(
      { required Function(List<ProjectGeoResultObjectModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required int projectId}) async {


    const String urlExtension = "Project/getgeolocation";

    performGetRequest(
        rawData: {"ProjectId":projectId},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectGeoResponseModel resultObj = ProjectGeoResponseModel.fromJson(result);
          if(resultObj.statusCode == 0){
            onRequestFailure(UnNamedMessage(resultObj.statusMessage));
          }else{
            onRequestSuccess(resultObj.locationList);
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }
}