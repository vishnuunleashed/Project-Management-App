
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/orientation.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_type_dropdown_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:intl/intl.dart';
import 'package:base/core/loader_value.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';

class AddSupportRequestProvider extends BaseProvider {
  int optionId = 0;
  int parentOptionId = 0;
  String optionName = "";
  int projectId = 0;
  int taskId = 0;
  DateTime transDate = DateTime.now();
  DateTime targetClosureDate = DateTime.now();
  List<DepartmentDropDownObj> departmentList = [];
  List<String> descFromDepartmentModel = [];
  DepartmentDropDownObj? selectedDeptObj;
  TextEditingController pointsController = TextEditingController(text: '');
  TextEditingController supOwnerController = TextEditingController(text: '');
  TextEditingController userController = TextEditingController(text: '');
  TextEditingController departmentController = TextEditingController(text: '');
  TextEditingController taskTypeController = TextEditingController(text: '');
  TextEditingController materialTypeController = TextEditingController(text: '');
  TextEditingController callTrackerTypeController = TextEditingController(text: '');
  TaskTypeDropdownDtlModel? selectedTaskType;
  CommonMasterModel? selectedMaterialType;
  CommonMasterModel? selectedCallTrackerType;
  CommonMasterModel? selectedCCMember;

  bool isFromSchedules =  false;
  bool isFromMaterialChart =  false;
  bool isFromCallTracker =  false;
  bool isFromMOM =  false;
  bool editSupport =  true;
  int supportId = 0;
  int recordId = 0;
  int callTrackerId = 0;

  List<String> editModeCCUser = [];
  String editModeowner = "";
  int? actionItemId;
  String callTrackerStatus = "";
  void setParameter(Map<String, dynamic>? extra,int projectId) {
    isFromSchedules = extra?['isFromSchedules'] ?? false;
    isFromMaterialChart = extra?['isFromMaterialChart'] ?? false;
    isFromCallTracker = extra?['IsFromCallTracker'] ?? false;
    isFromMOM = extra?['isFromMOM'] ?? false;
    taskId = extra?['taskId'] ?? 0;
    if(isFromSchedules){
      fetchTaskTypeDropDown();
    }
    if(isFromMaterialChart){
      recordId = extra?['recordId'];
      getMaterialSupportType();
    }
    if(isFromCallTracker){
      callTrackerId = extra?['callTrackerId'];
      getUserForCallTracker();
      getCallTrackerType();
    }
    if(extra != null && extra['isFromEditSupport'] != null){
      print("extra___ "+extra.toString());
      editSupport = extra['isFromEditSupport'] == false;
      supportId = extra['supportId'];
      pointsController.text = extra['points'] ?? "";
      editModeCCUser = extra["ccUsers"];
      editModeowner = extra["owner"];
      DateTime _targetClosureDate = DateTime.parse(extra["targetClosureDate"]);
      changeReqClosureDate(_targetClosureDate);
      isCritical = extra["isCritical"] == "Y";
    }else{
      editSupport =  true;
    }
    if(isFromMOM) {
       pointsController.text = extra?["supportRequestPoints"] ?? "";
       editModeowner = extra?["owner"] ?? "";
       actionItemId = extra?['actionItemId'];

    }
    notifyListeners();
    setProjectId(projectId: projectId ?? 0);
  }

  //To set project Id
  void setProjectId({required int projectId}) {
    this.projectId = projectId;
    fetchOwners();
    fetchProjectDetails(projectId: projectId??0);
    notifyListeners();
  }

  //To set option details
  void setOptionDetails({required UserRightsModel optionObj}) {
    optionId = optionObj.rightsData[0].optionId!;
    parentOptionId = optionObj.rightsData[0].parentOptionId!;
    optionName = optionObj.optionName!;
    notifyListeners();
  }

  void initValues() {
    transDate = DateTime.now();
    targetClosureDate = DateTime.now();
    pointsController = TextEditingController(text: '');
    supOwnerController = TextEditingController(text: '');
    materialTypeController = TextEditingController(text: '');
    callTrackerTypeController = TextEditingController(text: '');
    departmentController = TextEditingController(text: '');
    taskTypeController = TextEditingController(text: '');
    userController = TextEditingController(text: '');
    selectedDeptObj = null;
    selectedOwner = null;
    selectedUser = null;
    selectedCallTrackerType = null;
    selectedDeptObj = null;
    filteredOwners = owners;
    selectedTaskType = null;
    selectedMaterialType = null;
    isCritical = false;
    observers = [];
    observersFromUser = [];
    observersString = [];
    actionItemId = null;
    isFromMOM = false;
    notifyListeners();
  }

  //To Fetch Department Dropdown
  void fetchDepartmentDropDown() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchDepartmentDropDown(
        onRequestSuccess: (result) {
          departmentList = result;
          descFromDepartmentModel = departmentList.map((owner) => owner.desc).toList();

          if(!editSupport || isFromMOM){
            print("vishnu_here "+editModeowner+editModeCCUser.toString());
            if(owners.any((item)=> item.name.toLowerCase() == editModeowner.toLowerCase())){
              setSelectedOwner(editModeowner);
            }
            if(editModeCCUser.isNotEmpty){
              selectObservers(editModeCCUser);
            }

          }
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {});
  }


  List<OwnerModel> owners = [];

  OwnerModel? selectedOwner;
  EmployeeModel? selectedUser;

  List<OwnerModel> observers = [];
  List<EmployeeModel> observersFromUser = [];
  List<String> observersString = [];

  void selectObservers(List<String> selectedNames) {
    observersString = selectedNames;
    observers = owners
        .where((user) => selectedNames.contains(user.name))
        .toList();
    notifyListeners();
  }

  void selectCCMemberFromUsers(List<String> selectedNames) {
    observersString = selectedNames;
    observersFromUser = users
        .where((user) => selectedNames.contains(user.name))
        .toList();
    notifyListeners();
  }


  void removeObserver(String name) {
    observersString.remove(name);
    observers.removeWhere((user) => user.name == name);
    notifyListeners();
  }

  void removeObserverFromUser(String name) {
    observersString.remove(name);
    observersFromUser.removeWhere((user) => user.name == name);
    notifyListeners();
  }

  void setSelectedOwner(String name) {
    // if(isFiltered == true){
    //   selectedOwner = filteredOwners.firstWhere((owner) => owner.name == name);
    // }else{
      selectedOwner = owners.firstWhere((owner) => owner.name == name);
    // }
    // Auto-select corresponding department
    if (selectedOwner != null) {


      final matchingDept = departmentList.firstWhere(
            (dept) => dept.id == selectedOwner!.departmentId,
      );
      departmentController.text = matchingDept.desc;
      // if (matchingDept.id != 0) {
      //   selectedDeptObj = matchingDept;
      //   filteredOwners = owners.where((owner) => owner.departmentId == matchingDept.id).toList();
      //   isFiltered = true;
      // }
      supOwnerController = TextEditingController(text: selectedOwner?.name);
      print("Selected owner = ${supOwnerController.text}");

    }
    notifyListeners();
  }

  void setSelectedUser(EmployeeModel? name) {
    selectedUser = users.firstWhere((owner) => owner.id == name?.id);
    if (selectedUser != null) {
      final matchingDept = departmentList.firstWhere(
            (dept) => dept.id == selectedUser!.departmentid,
      );
      departmentController.text = matchingDept.desc;
      userController= TextEditingController(text: selectedUser?.name);

    }
    notifyListeners();
  }


  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchOwners(
        projectId: projectId ?? 0,
        excludeLoginUser: editSupport
            ? true
            : false,
        onRequestSuccess: (result) {
          owners = result;
          filteredOwners = result;

          fetchDepartmentDropDown();
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.success, message: "Owners fetched successfully"));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<OwnerModel> filteredOwners = [];



  //Change RequestedClosureDate
  void changeReqClosureDate(DateTime date) {
    targetClosureDate = date;
    notifyListeners();
  }
  //Save
  void addSupportRequest() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().addSupportRequest(
        addSupportRequestModel: AddSupportRequestModel(
            id: !editSupport ? supportId : 0,
            parentOptionId: parentOptionId,
            supportEdit: !editSupport,
            transDate: DateFormat('yyyy-MM-dd').format(transDate),
            requestDescription: pointsController.text,
            projectId: projectId,
            selectedOwnerId: isFromCallTracker?selectedUser?.id ?? 0:selectedOwner?.id ?? 0,
            dependencyDepId: selectedDeptObj?.id ?? 0,
            targetClosureDate:DateFormat('yyyy-MM-dd').format(targetClosureDate),
            fromTask: isFromSchedules ? true : false,
            supportTypeId: isFromCallTracker?selectedCallTrackerType?.id:selectedTaskType?.taskTypeId,
            fromAdditionalMat:isFromMaterialChart,
            observers:observers,
            observersFromUser:observersFromUser,
            isCritical:isCritical,
            materialTypeId:selectedMaterialType?.id,
            callTrackerTypeId: callTrackerId,
            fromCallTracker: isFromCallTracker,
            recordId:recordId,
            taskId: taskId,
            actionItemId: actionItemId,
            isFromMom: isFromMOM),
        onRequestSuccess: ({required String transNo}) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,message: "Support Request added successfully"));
                return BaseDialog.show(
                  transNo: "Trans no : $transNo",
                  context: NavigatorKey.navKey.currentContext!,
                    title: "Success",
                    message: "Support request added successfully",
                    icon: Icon(Icons.check_circle_outline,color: bayaInfraGreen,size: 36,),
                    actions: [
                      BaseElevatedButton(
                        borderRadius: 24,
                        onPressed: () {
                          initValues();
                          if(!editSupport){
                            print("entered");
                            GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                            GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                            ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context)
                                .read(mySupportProvider.notifier).refreshPage();
                            ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context)
                                .read(serviceSupportRequestSiteWiseProvider.notifier).fetchServiceSupportRequestSiteWiseList();
                            ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context)
                                .read(serviceDetailsSupportRequestProvider.notifier).fetchSupportRequestList();
                          }
                          GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                          final container = ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context);
                          HomeProvider _homeProvider = container.read(homeProvider);
                          _homeProvider.fetchPendingCount(projectIds: [projectId]);
                          notifyListeners();
                        },
                        backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                        text: "Ok",
                      ),
                    ]);
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void disposeVariables(){
    filteredOwners = [];
    selectedOwner = null;
    selectedDeptObj = null;
    selectedUser = null;
  }

  List<TaskTypeDropdownDtlModel> taskTypeDropdownList = [];
  void fetchTaskTypeDropDown(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchTaskTypeDropdown(
        onRequestSuccess: (result){
          taskTypeDropdownList = result;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  List<CommonMasterModel> materialSupportType = [];

  void getMaterialSupportType(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().getMaterialSupportType(
        onRequestSuccess: (result){
          materialSupportType = result;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }
  List<CommonMasterModel> callTrackerType = [];

  void getCallTrackerType(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().getCallTrackerType(
        onRequestSuccess: (result){
          callTrackerType = result;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  List<EmployeeModel> users = [];

  void getUserForCallTracker(){
    AddSupportRequestUseCase().getUserForCallTracker(
        onRequestSuccess: (result) async {
          users = result;
          int loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
          users.removeWhere((item){return item.id == loggedInUserId;});
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
  void setSelectedTaskType(TaskTypeDropdownDtlModel task) {
    selectedTaskType = task;
    taskTypeController.text = task.taskTypeDescription ?? "";
    notifyListeners();
  }

  void setMaterialType(CommonMasterModel type) {
    selectedMaterialType = type;
    materialTypeController.text = type.description ?? "";
    notifyListeners();
  }

  void setCallTrackerType(CommonMasterModel type) {
    selectedCallTrackerType = type;
    callTrackerTypeController.text = type.description ?? "";
    notifyListeners();
  }

  bool isCritical = false;
  void isCriticalMark() {
    isCritical= !isCritical;
    notifyListeners();
  }


  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchProjectDetails(
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





}