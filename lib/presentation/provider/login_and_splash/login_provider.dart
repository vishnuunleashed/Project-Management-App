import 'dart:async';
import 'dart:developer';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/login/login_model.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/utility/base_firebase.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:dcc_module/core/storage/dcc_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:interior_design/domain/usecase/login_usecase.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:workmanager/workmanager.dart';

class LoginProvider extends BaseProvider {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<String> sampleString = [];
  String loginUserProfilePicture = "";
  List<LoginResponseDto> loginDetails = [];
  final PageController pageController = PageController();
  int currentPage = 0;
  FirebaseNotificationHelper firebase = FirebaseNotificationHelper();
  final GlobalKey<FormState> loginFormKey = GlobalKey();
  final List<String> carouselTexts = [
    'Streamline your workflows and manage projects better',
    'Simplify your processes and boost team productivity',
    'Organize your work and deliver results faster',
    'Track performance and achieve project milestones easily',
  ];
  bool isInitialLoad = false;

  void changeLoginFlag(bool isInitialLoad){
    this.isInitialLoad = isInitialLoad;
    notifyListeners();
  }
  void changePage(int index) {
    currentPage = index;
    notifyListeners();
  }

  void disposeValues() {
    pageController.dispose();
    super.dispose();
  }

  void initValues() {
    isLoginProvider = true;
    userNameController = TextEditingController(text: "");
    passwordController = TextEditingController(text: "");
    notifyListeners();
  }
  void authenticate({required Function(MobileVersion?) onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    LoginUseCase().authenticate(
        username: userNameController.text.trim(),
        password: passwordController.text.trim(),
        onRequestSuccess: (loginResponse) async {
          loginDetails = loginResponse.loginResponse;
          firebase.subscribeTopics(loginDetails.first.notificationtopics);
          BaseSecureStorage.setString(BaseConstants.token, loginResponse.token ?? "");
          BaseSecureStorage.setString(BaseConstants.refreshToken, loginResponse.refreshToken ?? "");
          BaseSecureStorage.setInt(BaseConstants.userID, loginResponse.userID);
          BaseSecureStorage.setBool(BaseConstants.superUserYN,loginResponse.loginResponse.first.superUserYN == "Y");
          BaseSecureStorage.setInt(BaseConstants.departmentId, loginResponse.loginResponse.first.departmentId);
          BaseSecureStorage.setString(BaseConstants.departmentName, loginResponse.loginResponse.first.departmentName);
          BaseSecureStorage.setString(BaseConstants.departmentCode, loginResponse.loginResponse.first.departmentcode);
          BaseSecureStorage.setString(BaseConstants.userName, loginResponse.loginResponse.first.username ?? "");
          BaseSecureStorage.setString(BaseConstants.loginName, loginResponse.loginResponse.first.loginname ?? "");
          BaseSecureStorage.setString(BaseConstants.userEmailId,loginResponse.loginResponse.first.userEmailId);
          BaseSecureStorage.setInt(BaseConstants.companyId,loginResponse.loginResponse.first.companyid);
          BaseSecureStorage.setString(BaseConstants.phoneNo,loginResponse.loginResponse.first.phoneNo);
          BaseSecureStorage.setString(BaseConstants.profileImage, loginResponse.loginResponse.first.profileimage ?? "");
          BaseSecureStorage.setString(BaseConstants.loggedInUserProfileImageUrl, loginResponse.loginResponse.first.profileimageurl ?? "");
          BaseSecureStorage.setBool(BaseConstants.viewAllTaskYN, loginResponse.loginResponse.first.viewAllTaskYN == "Y");
          BaseSecureStorage.setBool(BaseConstants.isInitialLoad,false);
          BaseSecureStorage.setInt(BaseConstants.syncInterval,loginResponse.loginResponse.first.foregroundinterval);


          Workmanager().registerPeriodicTask("syncTask_1", "syncTask",
            initialDelay: Duration(minutes: 5),
            frequency: Duration(minutes: 15),
          );

          await DccModuleConfig.instance.init(
            tokenProvider: ()async => loginResponse.token,
            userIdProvider: () async=> loginResponse.userID,
            companyIdProvider: () async=> loginResponse.loginResponse.first.companyid,
            syncIntervalProvider: () async=>loginResponse.loginResponse.first.foregroundinterval,
            getClientId: () async=>Connections().clientId
          );
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          onSuccess(loginResponse.loginResponse.first.mobileVersion);
        },
        onRequestFailure: (exception) {
          String message = getErrorMessage(exception.toString());
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: AppException(message)));
        });
  }





  String getErrorMessage(String message) {
    if (message.contains('TKN_NFD')) {
      return 'Token not found';
    } else if (message.contains('INV_USR')) {
      return 'Sorry UserName Or Password is wrong';
    } else if (message.contains('INA_USR')) {
      return 'The status of this user is inactive. Therefore, login is not possible.';
    } else {
      return message; // Return original message if no code found
    }
  }



  void unsubscribeTopics() async {
    firebase.unsubscribeTopics();
  }



  Future<void> authenticateAutoLogin({required Function(MobileVersion?) onSuccess}) async {
    String refreshToken = await BaseSecureStorage.getString(BaseConstants.refreshToken);
    int userID = await BaseSecureStorage.getInt(BaseConstants.userID);
    LoginUseCase().authenticateAutoLogin(
        userID: userID,
        refreshToken: refreshToken,
        onRequestSuccess: (loginResponse) async {
          loginDetails = loginResponse.loginResponse;
          BaseSecureStorage.setString(BaseConstants.token, loginResponse.token ?? "");
          BaseSecureStorage.setString(BaseConstants.profileImage, loginResponse.resultObject.first['profileimage'] ?? "");
          BaseSecureStorage.setBool(BaseConstants.viewAllTaskYN, loginResponse.resultObject.first['viewalltaskyn'] == "Y");
          BaseSecureStorage.setString(BaseConstants.loggedInUserProfileImageUrl, loginResponse.loginResponse.first.profileimageurl ?? "");
          BaseSecureStorage.setInt(BaseConstants.companyId,loginResponse.loginResponse.first.companyid);
          BaseSecureStorage.setInt(BaseConstants.syncInterval,loginResponse.loginResponse.first.foregroundinterval);
          // Re-seed DCC module credentials on auto-login
          await DccModuleConfig.instance.init(
            tokenProvider: () async => loginResponse.token,
            userIdProvider: () async => await BaseSecureStorage.getInt(BaseConstants.userID),
            companyIdProvider: () async => loginResponse.loginResponse.first.companyid,
            syncIntervalProvider: () async => loginResponse.loginResponse.first.foregroundinterval,
            getClientId: ()async =>Connections().clientId
          );
          // Workmanager().registerPeriodicTask("syncTask_1", "syncTask",initialDelay: Duration(seconds: 30),frequency: Duration(minutes: 15));
          onSuccess(loginResponse.loginResponse.first.mobileVersion);
        },
        onRequestFailure: (exception) {
          // String message = getErrorMessage(exception.toString());
          // changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: AppException(exception.toString())));
          BaseSecureStorage.remove(BaseConstants.refreshToken);
          isFirstLaunch = true;
          notifyListeners();
        });
  }


  bool isFirstLaunch = false;
  void checkFirstLaunch({required Function() onFirstLaunch,required Function() onAutoLogin}) async {
    try {
      String refreshToken = await BaseSecureStorage.getString(BaseConstants.refreshToken);
      isFirstLaunch = refreshToken.isEmpty;
      if (isFirstLaunch) {

        onFirstLaunch();
      }else{

        onAutoLogin();
      }
    } on Exception catch (e) {
      isFirstLaunch = true;
      onFirstLaunch();
    }
    notifyListeners();


  }



}