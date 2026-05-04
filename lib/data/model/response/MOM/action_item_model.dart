import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';

class ActionItemModel {
  final int id;
  String description;
  OwnerModel? selectedOwner;
  List<ObservationDetailModel> observationList;

  final TextEditingController descriptionController;
  final TextEditingController ownerController;

  ActionItemModel({
    required this.id,
    required this.description,
    this.selectedOwner,
    this.observationList = const [],
  })  : descriptionController = TextEditingController(text: description),
        ownerController = TextEditingController(
          text: selectedOwner?.name ?? '',
        );

  void dispose() {
    descriptionController.dispose();
    ownerController.dispose();
  }
}