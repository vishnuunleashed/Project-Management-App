import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';

class  UploadModel{
  List<MaterialModel> initialMaterialsDataToBeUploaded = [];
  List<MaterialModel> specialMaterialsDataToBeUploaded = [];
  List<MaterialModel> standardMaterialsDataToBeUploaded = [];
  UploadModel({
    required this.initialMaterialsDataToBeUploaded,
    required this.specialMaterialsDataToBeUploaded,
    required this.standardMaterialsDataToBeUploaded});
}