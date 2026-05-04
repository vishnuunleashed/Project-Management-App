


import 'dart:io';

import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:eraser/eraser.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:geocoding/geocoding.dart';

import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_location/geo_location.dart';
import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';
import 'package:interior_design/domain/usecase/close_support_request/close_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/project_location/project_location_usecase.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/project_location/model/data_model_location.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:location/location.dart';
final LatLng fallbackKochi = const LatLng(9.9312, 76.2673);
class ProjectLocationProvider extends BaseProvider{

  List<PlaceModel> savedLocations = [];
  LatLng currentPosition = fallbackKochi;
  LatLng initialPosition = fallbackKochi;
  LatLng pickedPosition = fallbackKochi;

  double distanceKm = 0;

  TextEditingController radiusController = TextEditingController(text: "0.0");
  TextEditingController toleranceController = TextEditingController(text: "0.0");

  double? projectRadius;
  double? toleranceLimit;

  int? selectedIndex;
  List<ProjectGeoResultObjectModel> locationList = [];
  void initValues() {
    locationList= [];
    radiusController = TextEditingController(text: "0");
    toleranceController = TextEditingController(text: "0");
    savedLocations = [];
    currentPosition = fallbackKochi;
    initialPosition = fallbackKochi;
    pickedPosition = fallbackKochi;
    notifyListeners();
  }
  int projectId= 0;
  void setParameter(Map<String, dynamic>? extra) {
    if(extra != null && extra["projectId"] != null){
      projectId = int.parse(extra["projectId"].toString());
    }else if (extra != null && extra["transid"] != null){
      projectId = int.parse(extra["transid"].toString());
    }

    fetchProjectDetails(projectId: projectId);
  }

  Future<void> useCurrentLocation() async {
    final permission = await location.Location().requestPermission();
    if (permission == location.PermissionStatus.denied ||
        permission == location.PermissionStatus.deniedForever) {
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    LocationData position = await location.Location().getLocation();
    final placemarks = await placemarkFromCoordinates(
      position.latitude??0,
      position.longitude??0,
    );


    final place = placemarks.first;
    savedLocations.add(PlaceModel(
      distance: 0.0,
      title: "${place.street}",
      subtitle: "${place.locality}, ${place.subLocality}, ${place.administrativeArea}, ${place.postalCode}",
      lat: position.latitude??0,
      lng: position.longitude??0,
    ));
    initPosition(locationParams: LatLng(position.latitude??0, position.longitude??0));

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
  }




  void updateRadius(String v) {
    if (v.isEmpty) {
      projectRadius = null;
    } else {
      projectRadius = double.tryParse(v);
    }
    notifyListeners();
  }

  void updateTolerance(String v) {
    if (v.isEmpty) {
      toleranceLimit = null;
    } else {
      toleranceLimit = double.tryParse(v);
    }
    notifyListeners();
  }


  void selectLocation(int index) {
    selectedIndex = index;
    notifyListeners();
  }


  MapController mapController = MapController();

  Future initPosition({required LatLng locationParams}) async {
    final permission = await location.Location().requestPermission();
    if (permission == location.PermissionStatus.denied ||
        permission == location.PermissionStatus.deniedForever) {
      currentPosition = fallbackKochi;
      return;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    currentPosition = locationParams;
    pickedPosition = locationParams;
    mapController.moveAndRotate(locationParams, 16,0);
    notifyListeners();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}";
      }
    } catch (e) {
      return "Address not available";
    }
    return "Address not available";
  }

  Future<void> reCenter() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    mapController.rotate(0);
    mapController.move(currentPosition, 16.0);
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
  }

  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectLocationUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result) {
          projectDetailList = result;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
    notifyListeners();
  }



  void captureGeoLocation(){

    LocationParams params = LocationParams(
        projectId: projectId,
        latitude: savedLocations.first.lat,
        longitude: savedLocations.first.lng,
        allowedRadiusMeters: radiusController.text.toString(),
        geoTolerance: toleranceController.text.toString(),
        projectName: projectDetailList.first.projectName??'');
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
    ProjectLocationUseCase().captureGeoLocation(
        params: params,
        onRequestSuccess: (){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
           BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Success",
              message: "Project location saved successfully",
              icon: Icon(Icons.check_circle_outline,color: bayaInfraGreen,size: 36,),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,message: exception.message));
        });

  }







  Future<void> getGeoCoordinatedByProject({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectLocationUseCase().getGeoCoordinatedByProject(
      projectId: projectId,
      onRequestSuccess: (result) async {
        locationList = result;
        if(locationList.first.longitude != 0 && locationList.first.longitude != 0) {
          radiusController.text =
              locationList.first.allowedRadiusMeters.toString();
          toleranceController.text = locationList.first.geoTolerance.toString();
          final placemarks = await placemarkFromCoordinates(
            locationList.first.latitude,
            locationList.first.longitude,
          );

          final place = placemarks.first;
          savedLocations.add(PlaceModel(
            distance: 0.0,
            title: "${place.street}",
            subtitle: "${place.locality}, ${place.subLocality}, ${place
                .administrativeArea}, ${place.postalCode}",
            lat: locationList.first.latitude,
            lng: locationList.first.longitude,
          ));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            initPosition(locationParams: LatLng(
                locationList.first.latitude, locationList.first.longitude));
          });
        }

        notifyListeners();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, message: exception.toString()),
        );
      },
    );
  }

  int? notificationId;
  void setNotificationId(int id){
    notificationId =  id;
    updateNotificationStatus();
  }

  void updateNotificationStatus() {
    if(notificationId == null || notificationId == 0){
      return;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CloseSupportRequestUseCase().updateNotificationStatus(
        notificationId: notificationId??0,
        onRequestSuccess: (notificationId) {
          removeNotificationUsingIdList(notificationId);

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
  Future<void> removeNotificationUsingIdList(int notificationId) async {
    if(Platform.isAndroid) {
      print("notificationid_removed: " + notificationId.toString());
      Eraser.clearAppNotificationsById(notificationId);
    }

  }



}