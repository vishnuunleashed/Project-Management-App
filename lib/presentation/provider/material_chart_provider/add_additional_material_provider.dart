import 'package:base/core/loader_value.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/material_chart/brand_model.dart' show BrandResultObject, BrandModel;
import 'package:interior_design/data/model/response/material_chart/uom_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/domain/usecase/material_chart/material_chart_usecase.dart';
import 'package:interior_design/presentation/view/material_chart/model/params_model.dart';
import 'package:intl/intl.dart';

import 'material_chart_provider.dart';

class AdditionalMaterialChartProvider extends BaseProvider{
  TextEditingController reasonController = TextEditingController(text: "");
  TextEditingController brandTypeController = TextEditingController(text: "");
  TextEditingController reasonTypeController = TextEditingController(text: "");
  TextEditingController requiredByController = TextEditingController(text: "");
  TextEditingController quantityController = TextEditingController(text: "");
  TextEditingController wastageController = TextEditingController(text: "0");
  TextEditingController workItemController = TextEditingController(text: "");
  TextEditingController materialNameController = TextEditingController(text: "");
  TextEditingController uomController = TextEditingController(text: "");
  List<UomModel> uomList = [];
  List<CommonMasterModel> reasonType = [];
  List<BrandModel> brandType = [];

  void initValues(){
    reasonController.clear();
    reasonTypeController.clear();
    requiredByController.clear();
    quantityController.clear();
    brandTypeController.clear();
    wastageController.clear();
    workItemController.clear();
    materialNameController.clear();
    uomController.clear();
    selectedUser = null;
    selectedUOM = null;
    selectedReasonType = null;
    selectedBrandType = null;

    requiredDate = DateTime.now();
  }

  int projectId = 0;

  DateTime requiredDate = DateTime.now();

  void setParameter(Map<String, dynamic>? extra) {
    if(extra != null){
      projectId = extra["projectId"];
      fetchProjectDetails();
      getUoms();
      fetchOwners();
      getReasonType();
      getBrandType();
    }
  }
  List<ProjectDetailsModel> projectDetailList = [];

 List<OwnerModel> requiredByUserList = [];

  OwnerModel? selectedUser;
  UomModel? selectedUOM;
  CommonMasterModel? selectedReasonType;
  BrandModel? selectedBrandType;


  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().fetchOwners(
        projectId: projectId ?? 0,
        excludeLoginUser: false,
        onRequestSuccess: (result) {
          requiredByUserList = result;

          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.success, message: "Owners fetched successfully"));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void fetchProjectDetails(){
    MaterialChartUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result){
          projectDetailList = result;
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
  }

  void getUoms(){
    uomList = [];
    MaterialChartUseCase().getUoms(
         onRequestSuccess: (uomList){
          this.uomList = uomList;
          notifyListeners();
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }
  void getReasonType(){
    MaterialChartUseCase().getReasonType(
         onRequestSuccess: (reasonType){
          this.reasonType = reasonType;
          notifyListeners();
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  void getBrandType(){
    MaterialChartUseCase().getBrandType(
         onRequestSuccess: (brands){
           if(brands.isNotEmpty){
              brandType = brands.first.list;
           }
          notifyListeners();
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  void changeDate(DateTime date) {
    requiredDate = date;
    notifyListeners();
  }


  void setSelectedUser(String name) {
    selectedUser = requiredByUserList.firstWhere((owner) => owner.name == name);
    if (selectedUser != null) {
      requiredByController = TextEditingController(text: selectedUser?.name);
    }
    notifyListeners();
  }


  void setSelectedUom(String name) {
    selectedUOM = uomList.firstWhere((owner) => owner.uomDescription == name);
    if (selectedUOM != null) {
      uomController = TextEditingController(text: selectedUOM?.uomDescription);
    }
    notifyListeners();
  }

  void setSelectedReasonType(String description) {
    selectedReasonType = reasonType.firstWhere((owner) => owner.description == description);
    if (selectedReasonType != null) {
      reasonTypeController = TextEditingController(text: selectedReasonType?.description);
    }
    notifyListeners();
  }
  void setSelectedBrandType(BrandModel? brand) {
    selectedBrandType = brand;
    brandTypeController.text = brand?.name??"";
    notifyListeners();
  }

  int? parentOptionId;
  String optionName = '';
  void setOptionDtl({required UserRightsModel optionObj}) {
    parentOptionId = optionObj.rightsData[0].parentOptionId ;
    optionName = optionObj.optionName!;
    notifyListeners();
  }


  void saveMaterial({required Function() onRequestSuccess,
      required Function(AppException exception) onRequestFailure,}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().saveMaterial(
        addMaterialChartRequest: AddMaterialChartRequest(
            projectId: projectId,
            optionCode: "ADDT_MAT_CHART",
            optionId: parentOptionId??0,
            detailsList: [MaterialDetail(
              brandId: selectedBrandType?.id??0,
            wastagePerc: wastageController.text.isNotEmpty?int.parse(wastageController.text):0,
            name: materialNameController.text,
            workItem: workItemController.text,
            qty: int.parse(quantityController.text),
            uomId: selectedUOM?.uomId??0,
            reasonId: selectedReasonType?.id??0,
            reason: reasonController.text.isEmpty?selectedReasonType?.description??"":reasonController.text,
            requiredDate: DateFormat('dd-MM-yyyy').format(requiredDate))
        ]),
        onRequestSuccess: (){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          onRequestSuccess();
        },
        onRequestFailure: onRequestFailure);
  }


}