
import 'package:base/data/models/response/option_list_model.dart';

class OptionListLocator{
  List<OptionListModel>? optionList;

  void updateData(List<OptionListModel> optionModelList){
    optionList = optionModelList;
  }
}
