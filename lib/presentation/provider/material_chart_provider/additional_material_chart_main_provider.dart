import 'dart:async';
import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/all_reason_type_mode.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/usecase/material_chart/material_chart_usecase.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/additional_material_chart_widget.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';

class AdditionalMaterialMainProvider extends BaseProvider {
  List<MaterialRequestModel> additionalMaterial = [];
  List<MaterialRequestModel> additionalMaterialWithPurchaseOrder = [];
  int projectId = 0;
  // int parentOptionId = 0;
  String flag = "";
  List<bool> isSelected = [true, false];
  int loggedInUserID = 0;
  bool isSuperUser = false;
  bool isProjectDepartment = false;

  String selectedTab = 'AM';
  DateTime recievedData = DateTime.now();
  ScrollController listController = ScrollController();

  // Store scroll position
  double _savedScrollPosition = 0.0;
  bool _shouldRestorePosition = false;

  Future<void> initState() async {
    isSelected = [true, false];
    pageController = PageController(initialPage: 0);
    loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    isProjectDepartment =
        await BaseSecureStorage.getString(BaseConstants.departmentCode) ==
            "PRJ";
    additionalMaterial = [];
    images = [];
    attachmentUrl = [];
    additionalMaterialWithPurchaseOrder = [];

    // Setup scroll controller listener to save position
    _setupScrollListener();
  }

  void _setupScrollListener() {
    listController.addListener(() {
      if (listController.hasClients) {
        _savedScrollPosition = listController.position.pixels;
      }
    });
  }

  // Method to save current scroll position before refresh
  void _saveScrollPosition() {
    if (listController.hasClients) {
      _savedScrollPosition = listController.position.pixels;
      _shouldRestorePosition = true;
    }
  }

  // Method to restore scroll position after refresh
  void _restoreScrollPosition() {
    if (_shouldRestorePosition && listController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (listController.hasClients &&
            _savedScrollPosition <= listController.position.maxScrollExtent) {
          listController.jumpTo(_savedScrollPosition);
        }
        _shouldRestorePosition = false;
      });
    }
  }

  PageController pageController = PageController(initialPage: 0);
  int currentPage = 1;
  int userId = 0;
  String teamYn = "N";
  String tabName = "Update Recvd Qty";
  bool viewAll = false;

  Future<void> setParams({Map<String, dynamic>? extra}) async {
    initState();
    projectId = extra!["projectId"] ?? 0;
    flag = extra["flag"] ?? "";
    teamYn = extra["teamYn"] ?? "N";
    viewAll = extra["viewAll"] ?? false;
    userId =
        extra["userId"] ?? await BaseSecureStorage.getInt(BaseConstants.userID);
    if (flag == "PEND_APPROVAL") {
      tabName = 'Approval Pending';
    } else if (flag == "RECEIVED_QTY") {
      tabName = 'Receipt Pending';
    } else if (flag == 'EXCEED_REC_QTY') {
      tabName = 'Receipt Delayed';
    } else if (flag == 'SEND_BACK') {
      tabName = 'Send Back';
    } else if (flag == 'PO_UPDATE') {
      tabName = 'PO Pending';
    }
    notifyListeners();
    fetchAdditionalMaterialChart();
    fetchAllAdditionalMaterialChart();
  }

  int selectedOptionIndex = 0;
  void onPageChanged(int index) {
    selectedOptionIndex = index;
    notifyListeners();
  }

  void fetchAdditionalMaterialChart({bool retainScroll = false}) {
    // Save scroll position if needed
    if (retainScroll) {
      _saveScrollPosition();
    }

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().fetchAdditionalMaterialChart(
        projectId: projectId,
        flag: flag,
        teamYn: teamYn,
        userId: userId,
        onRequestSuccess: (result) {
          // Only update if data has actually changed
          if (additionalMaterialWithPurchaseOrder.isEmpty ||
              !_areListsEqual(additionalMaterialWithPurchaseOrder, result)) {
            additionalMaterialWithPurchaseOrder = result;
            notifyListeners();
            print("entered__ " +
                additionalMaterialWithPurchaseOrder.length.toString());
          }

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));

          // Restore scroll position after notifyListeners
          if (retainScroll) {
            _restoreScrollPosition();
          }
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void fetchAllAdditionalMaterialChart({bool retainScroll = false}) {
    // Save scroll position if needed
    if (retainScroll) {
      _saveScrollPosition();
    }

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().fetchAdditionalMaterialChart(
        projectId: projectId,
        flag: "",
        teamYn: teamYn,
        userId: userId,
        onRequestSuccess: (result) {
          if (result.isNotEmpty) {
            // Only update if data has actually changed
            if (!_areListsEqual(additionalMaterial, result)) {
              additionalMaterial = result;
            }
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();

          // Restore scroll position after notifyListeners
          if (retainScroll) {
            _restoreScrollPosition();
          }
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  // Helper method to compare lists and detect actual changes
  bool _areListsEqual(
      List<MaterialRequestModel> list1, List<MaterialRequestModel> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (!_areMaterialRequestsEqual(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }

  // Helper method to compare individual MaterialRequestModel objects
  bool _areMaterialRequestsEqual(
      MaterialRequestModel item1, MaterialRequestModel item2) {
    return item1.id == item2.id &&
        item1.name == item2.name &&
        item1.qty == item2.qty &&
        item1.approvalStatus == item2.approvalStatus &&
        item1.approvalYn == item2.approvalYn &&
        item1.receivedQty == item2.receivedQty &&
        item1.balanceQty == item2.balanceQty &&
        item1.poIssuedYn == item2.poIssuedYn &&
        item1.poIssuedQty == item2.poIssuedQty &&
        item1.receivedYn == item2.receivedYn &&
        item1.expectedDeliveryDate == item2.expectedDeliveryDate &&
        item1.lastReceivedDate == item2.lastReceivedDate &&
        item1.lastModDate == item2.lastModDate;
  }

  // Public method to refresh data while retaining scroll position
  void refreshData() {
    fetchAdditionalMaterialChart(retainScroll: true);
    fetchAllAdditionalMaterialChart(retainScroll: true);
  }

  String attachmentSeriesNo = '';
  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await MaterialChartUseCase().uploadImageFile(
        file: file,
        uploadProgress: (progress) {
          loadingProgress = progress;
          notifyListeners();
        },
        attachmentSerialNo: attachmentSeriesNo,
        onRequestSuccess: (response) {
          addImage(response);
          attachmentSeriesNo = response.last.serialno ?? "";
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<UploadResponse> images = [];
  List<AttachmentModel> attachmentUrl = [];

  void addImage(List<UploadResponse> file) {
    images.addAll(file);
    attachmentUrl
        .addAll(file.map((e) => AttachmentModel(url: e.url ?? "")).toList());
    notifyListeners();
  }

  void updateQuantityAdditionMaterial({
    required MaterialQtyUpdateRequest materialQtyUpdateRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    MaterialChartUseCase().updateQuantityAdditionMaterial(
        materialQtyUpdateRequest: materialQtyUpdateRequest,
        onRequestSuccess: () {
          onRequestSuccess();
        },
        onRequestFailure: onRequestFailure);
  }

  //For view uploaded images
  Future<void> fetchAttachmentsDetail({
    required List<UploadResponse> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    MaterialChartUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl.addAll(result.attachmentUrl);
        notifyListeners();
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }

  void initDialog() {
    images = [];
    attachmentUrl = [];
    notifyListeners();
  }

  @override
  void dispose() {
    listController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void setRecievedDate(DateTime date) {
    recievedData = date;
    notifyListeners();
  }
}
