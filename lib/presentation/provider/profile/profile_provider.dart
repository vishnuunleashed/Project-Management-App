import 'dart:async';
import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/usecase/profile/profile_usecase.dart';

import '../../../data/model/response/add_observation/add_observation_model.dart';

class ProfileProvider extends BaseProvider {
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmNewPassController = TextEditingController();
  TextEditingController usernameEmailController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String profileImageUrl= '';
  Future<void> initValues() async {

    print("profileImageUrl__ "+profileImageUrl);
    oldPassController = TextEditingController(text: "");
    newPassController = TextEditingController(text: "");
    confirmNewPassController = TextEditingController(text: "");
    usernameEmailController = TextEditingController(text: "");
    notifyListeners();
  }



  String userName = "";
  String loginName = "";
  int department = 0;
  String departmentName = "";
  String userEmailId = "";
  String phoneNo = "";

  Future<void> getUserName() async{
    profileImageUrl = await  BaseSecureStorage.getString(BaseConstants.loggedInUserProfileImageUrl);
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    loginName =  await BaseSecureStorage.getString(BaseConstants.loginName);
    department = await BaseSecureStorage.getInt(BaseConstants.departmentId);
    departmentName = await BaseSecureStorage.getString(BaseConstants.departmentName);
    userEmailId = await BaseSecureStorage.getString(BaseConstants.userEmailId);
    phoneNo = await BaseSecureStorage.getString(BaseConstants.phoneNo);
    notifyListeners();
  }



  Future<void> changePassword({required Function onSuccess}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProfileUseCase().changePassword(
        oldPassword: oldPassController.text,
        newPassword: newPassController.text,
        onRequestSuccess: () {
          onSuccess();
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (e) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
  }

  Future<void> forgotPassword({required Function onSuccess}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProfileUseCase().forgotPassword(
       usernameOrEmail: usernameEmailController.text,
        onRequestSuccess: () {
          onSuccess();
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (e) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error,exception: e));
        }
        );
  }


  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await ProfileUseCase().uploadImageFile(
        file: file,
        uploadProgress: (progress){
          print("progress__ "+progress.toString());
          loadingProgress = progress;
          notifyListeners();
        },
        onRequestSuccess: (response) {
          fetchAttachmentsDetail(attachmentList: response);
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });


  }

  List<AttachmentModel> attachmentUrl = [];
  //For view uploaded images
  Future<void> fetchAttachmentsDetail({
    required List<UploadResponse> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProfileUseCase().fetchAttachmentsDetail(
      isProfilePic: true,
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl = result.attachmentUrl;
        profileImageUrl = attachmentUrl.first.url;

        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }

  void clearProfileProviderData(){
    attachmentUrl = [];
    notifyListeners();
  }

  Future<void> refreshAttachmentsDetail() async {
    final userProfileImage =  await BaseSecureStorage.getString(BaseConstants.profileImage);
    if(userProfileImage != null && userProfileImage != "") {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
      ProfileUseCase().fetchAttachmentsDetail(
        isProfilePic: true,
        attachmentList: [UploadResponse(physicalfilename: userProfileImage)],
        onRequestSuccess: (result) {
          attachmentUrl = result.attachmentUrl;
          profileImageUrl = attachmentUrl.first.url;

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        },
      );
    }
  }

  void updateUserName(String name) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProfileUseCase().updateUserName(
      name: name,
      onRequestSuccess: (result) async {
        if(result != "Failure"){
          loginName = result;
          await BaseSecureStorage.setString(BaseConstants.loginName,result);
          notifyListeners();
        }else{
          BaseSnackBar().show(message: "Failure");
        }
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error));
      },
    );


 }
}
