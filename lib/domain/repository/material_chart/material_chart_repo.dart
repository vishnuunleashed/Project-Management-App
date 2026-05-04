import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_detail_model.dart';
import 'package:interior_design/data/model/response/material_chart/all_reason_type_mode.dart';
import 'package:interior_design/data/model/response/material_chart/brand_model.dart';
import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/uom_model.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/additional_material_chart_widget.dart';
import 'package:interior_design/presentation/view/material_chart/generalized_tabs.dart';
import 'package:interior_design/presentation/view/material_chart/model/params_model.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/presentation/view/material_chart/partials/upload_model.dart';

abstract class MaterialChartRepository extends BaseRepository{
  Future<void> fetchMaterialChart(
      {required int projectId,
        required Function(List<MaterialDetailsWrapperModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> updateIGFCQuantity({
    required UploadModel uploadModel,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  Future<void> verifyIGFCQuantities({
    required int projectId,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });
  void getUoms(
      {
        required Function(List<UomModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});
  void getReasonType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  void saveMaterial({
    required AddMaterialChartRequest addMaterialChartRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  Future<void> fetchAdditionalMaterialChart(
      {required int projectId,
        required String flag,
        required String teamYn,
        required int userId,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> updateQuantityAdditionMaterial({
    required MaterialQtyUpdateRequest materialQtyUpdateRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void getRoleWiseReasonListByUser(
      {required Function(List<ProjectRoleOptionModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  void updateStatus(
      {required ProjectApprovalModel statusModel,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});
  void getBrandType(
      {required Function(List<BrandResultObject>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  void fetchDetailedAdditionalMaterial(
      {
        required int id,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});


}