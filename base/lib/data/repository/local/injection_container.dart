// import 'package:base/data/models/local_injector_model/bluetooth_device.dart';
// import 'package:base/data/models/local_injector_model/current_screen.dart';
// import 'package:base/data/models/local_injector_model/initil_load.dart';
// import 'package:base/data/models/local_injector_model/option_list.dart';
// import 'package:base/data/models/local_injector_model/pending_data_list.dart';
// import 'package:base/data/models/response/login_response.dart';
// import 'package:base/data/models/response/option_list_model.dart';
// import 'package:base/data/models/response/profile/pending_order_model.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:get_it/get_it.dart';
//
// class BaseServiceLocator {
//   static final baseServiceLocator = GetIt.instance;
//   static LoginModules loginModules = baseServiceLocator<LoginModules>();
//   static PendingDataList pendingDataList =
//   baseServiceLocator<PendingDataList>();
//   static init() {
//     baseServiceLocator
//         .registerLazySingleton<LoginModules>(() => LoginModules());
//     baseServiceLocator
//         .registerLazySingleton<OptionListLocator>(() =>OptionListLocator());
//     baseServiceLocator
//         .registerLazySingleton<PendingDataListLocator>(() =>PendingDataListLocator());
//
//     baseServiceLocator.registerLazySingleton<CurrentScreen>(() =>CurrentScreen());
//     baseServiceLocator.registerLazySingleton<InitialLoad>(() =>InitialLoad());
//     baseServiceLocator.registerLazySingleton<BluetoothDevices>(() =>BluetoothDevices());
//     registerpendingDataListFromProfile(PendingDataList());
//   }
//
//   static void moduleListRegister(List<ModuleListModel> moduleList) {
//     loginModules.moduleListModel = moduleList;
//   }
//
//   static List<ModuleListModel> getModuleList() {
//     return baseServiceLocator.get<LoginModules>().moduleListModel;
//   }
//
//   static void optionListRegister(List<OptionListModel> optionModelList) {
//     final myService = baseServiceLocator<OptionListLocator>();
//     myService.updateData(optionModelList);
//   }
//
//   static List<OptionListModel>? getOptionList() {
//     return baseServiceLocator.get<OptionListLocator>().optionList;
//   }
//
//
//   static void registerUserInfo(List<UserInfoModel> userInfo) {
//     loginModules.userInfo = userInfo;
//   }
//
//   static List<UserInfoModel> getUserInfo() {
//     return baseServiceLocator.get<LoginModules>().userInfo;
//   }
//
//   static void registerpendingDataListFromProfile(
//       PendingDataList pendingDataListAsArgs) {
//     final myService = baseServiceLocator<PendingDataListLocator>();
//     myService.updateData(pendingDataListAsArgs);
//   }
//
//   static PendingDataList getpendingDataListFromProfile() {
//     return baseServiceLocator.get<PendingDataListLocator>().pendingDataList;
//   }
//
//
//
//   static void registerCurrentScreen(String screenArgs) {
//     final myService = baseServiceLocator<CurrentScreen>();
//     myService.updateData(screenArgs);
//   }
//
//
//   static String getCurrentScreen() {
//     return baseServiceLocator.get<CurrentScreen>().currentScreen;
//   }
//   static void registerInitialLoad(bool isInitialArgs) {
//     final myService = baseServiceLocator<InitialLoad>();
//     myService.updateData(isInitialArgs);
//   }
//
//
//   static bool getInitialLoad() {
//     return baseServiceLocator.get<InitialLoad>().initialLoad;
//   }
//
//   static void registerBluetoothDevice(
//       BluetoothDevice bluetoothDevice) {
//     final myService = baseServiceLocator<BluetoothDevices>();
//     myService.updateDevice(bluetoothDevice);
// }
//
//   static BluetoothDevice getBluetoothDevice() {
//     return baseServiceLocator.get<BluetoothDevices>().bluetoothDevice;
//   }
//
//
// }
//
