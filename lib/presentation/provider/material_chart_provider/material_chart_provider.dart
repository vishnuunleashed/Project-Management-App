import 'dart:convert';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';
import 'package:interior_design/domain/usecase/material_chart/material_chart_usecase.dart';
import 'package:interior_design/presentation/view/material_chart/generalized_tabs.dart';
import 'package:interior_design/presentation/view/material_chart/material_chart_screen.dart';
import 'package:interior_design/presentation/view/material_chart/partials/chart_model.dart';
import 'package:interior_design/presentation/view/material_chart/partials/upload_model.dart';


class MaterialChartProvider extends BaseProvider{
  List<MaterialDetailsWrapperModel> materialItem = [];
  List<MaterialModel> initialMaterials = [];
  List<MaterialModel> initialMaterialsRawData = [];
  List<MaterialModel> specialMaterials = [];
  List<MaterialModel> specialMaterialsRawData = [];
  List<MaterialModel> standardMaterials = [];
  List<MaterialModel> standardMaterialsRawData = [];


  MenuItems? selectedCategory;
  bool isSelected = false;
  int projectId = 0;

  PageController pageController = PageController();

  List<MenuItems> menuCategory = [];

  ScrollController scrollController = ScrollController();

  void clearData(){
    materialItem = [];
    initialMaterials = [];
    initialMaterialsRawData=[];
    specialMaterials = [];
    specialMaterialsRawData=[];
    standardMaterials =[];
    standardMaterialsRawData=[];


  }


  void initializeMenu(List<MaterialDetailsWrapperModel> result){
    clearData();
    materialItem = result;
    initialMaterials = result.first.initialMaterials.map((e) => e.copyWith()).toList();
    initialMaterialsRawData = result.first.initialMaterials.map((e) => e.copyWith()).toList();
    specialMaterials = result.first.specialMaterials.map((e) => e.copyWith()).toList();
    specialMaterialsRawData = result.first.specialMaterials.map((e) => e.copyWith()).toList();
    standardMaterials = result.first.standardMaterials.map((e) => e.copyWith(isTempMaterialChart: true)).toList();
    standardMaterialsRawData = result.first.standardMaterials.map((e) => e.copyWith(isTempMaterialChart: true)).toList();

    menuCategory = [
      if(initialMaterials.isNotEmpty)
        MenuItems(index: 0, menuName: 'Initial Base Material Chart'),
      if(specialMaterials.isNotEmpty)
        MenuItems(index: 1, menuName: 'Special Finishes Material'),
      if(standardMaterials.isNotEmpty)
        MenuItems(index: 2, menuName: 'Temporary Material'),
    ];
    notifyListeners();
  }

  void setParameter(Map<String,dynamic>? extra){
    if(extra != null){
      projectId = extra["projectId"];
      initValue();
      fetchMaterialChart();
    }

  }

  void selectCategoryByIndex({
    required int index,
  }) {
    if(index == 0){
      selectedCategory = MenuItems(index: 0, menuName: 'Initial Base Material Chart');
    }else if(index == 1){
      selectedCategory = MenuItems(index: 1, menuName: 'Special Finishes Material');

    }else if(index == 2){
      selectedCategory = MenuItems(index: 2, menuName: 'Temporary Material');
    }else if(index == 3){
      selectedCategory = MenuItems(index: 3, menuName: 'Additional Material');
    }
    notifyListeners();
  }


  void fetchMaterialChart(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().fetchMaterialChart(
        projectId: projectId,
        onRequestSuccess: (result){
          if(result.isNotEmpty){
            initializeMenu(result);

          }
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
            changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
          }
        );
  }







  List<MaterialModel> getIgfcQtyChangedMaterials({
    required MaterialChartType materialType,
    required List<MaterialModel> rawData,
    required List<MaterialModel> updatedList,
  }) {
    // Create lookup map for initial data
    final Map<int?, MaterialModel> initialMap = {
      for (final item in rawData) item.id: item,
    };

    return updatedList.where((updatedItem) {
      final initialItem = initialMap[updatedItem.id];

      if (initialItem == null) return false;

      double? initialQty;
      double? updatedQty;
      if(materialType == MaterialChartType.standard){
         initialQty = initialItem.qty ?? 0;
         updatedQty = updatedItem.qty ?? 0;
      }else{

        initialQty = initialItem.igfcQty ?? 0;
         updatedQty = updatedItem.igfcQty ?? 0;

      }

      return initialQty != updatedQty;
    }).toList();
  }
  void updateIGFCQuantity({required List<MaterialModel> initialMaterials,
      required List<MaterialModel> specialMaterials,
      required List<MaterialModel> standardMaterials,
      }){
    List<MaterialModel> initialMaterialsDataToBeUploaded = [];
    List<MaterialModel> specialMaterialsDataToBeUploaded = [];
    List<MaterialModel> standardMaterialsDataToBeUploaded = [];
    initialMaterialsDataToBeUploaded.addAll(getIgfcQtyChangedMaterials(
        materialType: MaterialChartType.initial,
        updatedList: initialMaterials,
        rawData: initialMaterialsRawData));
    specialMaterialsDataToBeUploaded.addAll(getIgfcQtyChangedMaterials(
        materialType: MaterialChartType.special,
        updatedList: specialMaterials,
        rawData: specialMaterialsRawData));
    standardMaterialsDataToBeUploaded.addAll(getIgfcQtyChangedMaterials(
        materialType: MaterialChartType.standard,
        updatedList: standardMaterials,
        rawData: standardMaterialsRawData));
    if(initialMaterialsDataToBeUploaded.isEmpty && specialMaterialsDataToBeUploaded.isEmpty && standardMaterialsDataToBeUploaded.isEmpty){
      BaseSnackBar().show(message: "No updates found in IGFC quantities");
      return;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().updateIGFCQuantity(
        uploadModel: UploadModel(
          initialMaterialsDataToBeUploaded: initialMaterialsDataToBeUploaded,
            specialMaterialsDataToBeUploaded: specialMaterialsDataToBeUploaded,
            standardMaterialsDataToBeUploaded: standardMaterialsDataToBeUploaded,
        ),
        onRequestSuccess: (){

          showDialogBox(
              context: NavigatorKey.navKey.currentState!.context,
              title: "Success",
              iconColor: bayaInfraGreen,
              titleIcon: Icons.check_circle_outline,
              buttonType: DialogButtonType.okOnly,
              action: (){
                FocusManager.instance.primaryFocus?.unfocus();
                fetchMaterialChart();
                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
              },
              message: "IGFC quantity updated successfully");
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
            changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,message: exception.toString()));
          }
        );
  }

  void verifyIGFCQuantities(){

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().verifyIGFCQuantities(
        projectId: projectId,
        onRequestSuccess: (){

          fetchMaterialChart();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        }
    );
  }


  void updateIgfcQtInitialMaterialsy(int index, String value) {
    initialMaterials[index].igfcQty = double.tryParse(value);

  }


  void updateIgfcQtySpecialMaterials(int index, String value) {
    specialMaterials[index].igfcQty = double.tryParse(value);

  }


  void updateIgfcQtyStandardMaterials(int index, String value) {
    standardMaterials[index].qty = double.tryParse(value);
    notifyListeners();
  }
  bool isProjectDepartment = false;
  bool isSuperUser = false;
  Future<void> initValue() async {
    isProjectDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRJ";
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }

  int selectedTabIndex = 0;

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchAdditionalMaterials() async {
    // Fetch from API and parse JSON
    // additionalMaterials = parsedData;
    notifyListeners();
  }


}
