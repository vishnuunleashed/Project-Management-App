import 'dart:async';
import 'dart:math';

import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/request/call_tracker/new_service_add_model.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/location_address_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_service_request_usecase.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_tasks_provider.dart';
import 'package:intl/intl.dart';



class AddServiceRequestProvider extends ServiceTasksProvider {
  // Text Controllers
  final TextEditingController ticketNoController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController siteController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController engineerController = TextEditingController();
  final TextEditingController reporterController = TextEditingController();
  final TextEditingController closureDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Selected Values
  CommonMasterModel? selectedClient;
  CommonMasterModel? selectedCity;
  LocationModelAddresses? selectedLocation;
  String? selectedType;
  String? selectedStatus;
  String? selectedCategory;
  String? selectedPriority;
  String? selectedEngineer;
  String? selectedReporter;
  DateTime? selectedClosureDate;

  // Show/Hide Select Location Button
  bool showSelectLocationButton = false;

  // Edit Mode


  // Dummy Data Lists
  List<CommonMasterModel> clientList = [];

  void fetchClientLists(){
    AddServiceRequestUsecase().fetchClientLists(
        onRequestSuccess: (result){
          clientList = result;
          notifyListeners();
          // If in edit mode and we just loaded clients, populate the form
          if (isEditMode && currentTicket != null) {
            _setClientFromTicket();
          }
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  // Dummy Data Lists
  List<CommonMasterModel> cityList = [];

  void fetchCityLists(){
    AddServiceRequestUsecase().fetchCityLists(
        onRequestSuccess: (result){
          cityList = result;
          notifyListeners();
          // If in edit mode and we just loaded clients, populate the form
          if (isEditMode && currentTicket != null) {
            _setCityFromTicket();
          }
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<LocationModelAddresses> locationList = [];

  void fetchLocationAddress(int clientId){
    locationList = [];
    AddServiceRequestUsecase().fetchLocationAddress(
        clientId: clientId,
        onRequestSuccess: (result){
          locationList = result;
          showSelectLocationButton = true;

          // Don't clear fields in edit mode
          if (!isEditMode) {
            selectedLocation = null;
            siteController.clear();
            buildingController.clear();
            floorController.clear();
            addressController.clear();
          } else if (currentTicket != null) {
            // Try to find matching location in edit mode
            _setLocationFromTicket();
          }

          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<CommonMasterModel> categoryList = [];

  void fetchServiceCategory(){
    AddServiceRequestUsecase().fetchServiceCategory(
        onRequestSuccess: (result){
          categoryList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<CommonMasterModel> priorityList = [];

  void fetchServicePriority(){
    AddServiceRequestUsecase().fetchServicePriority(
        onRequestSuccess: (result){
          priorityList = result;
          notifyListeners();
        },
        onRequestFailure:  (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

 List<CommonMasterModel> engineerList = [];
List<CommonMasterModel> reporterList = [];
List<CommonMasterModel> coordinatorDepart = [];
List<CommonMasterModel> engineerListTemp = [];


Future<List<CommonMasterModel>> _fetchByDepartment(String departmentCode) {
  final completer = Completer<List<CommonMasterModel>>();
  AddServiceRequestUsecase().fetchUserByDepartment(
    departmentCode: departmentCode,
    onRequestSuccess: (List<CommonMasterModel> result) => completer.complete(result),
    onRequestFailure: (exception) {
      changeLoadingStatus(
        loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
      );
      completer.complete([]);
    },
  );
  return completer.future;
}


void fetchAllUserByDepartment( ) {
  AddServiceRequestUsecase().fetchAllUserByDepartment(
    onRequestSuccess: (List<CommonMasterModel> result){
      result.sort((a, b) => (a.name ?? '').toLowerCase()
          .compareTo((b.name ?? '').toLowerCase()));
      engineerList = result;
      notifyListeners();
    },
    onRequestFailure: (exception) {
      changeLoadingStatus(
        loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
      );

    },
  );

}

  void fetchUserByProjectDepartment() async {
    AddServiceRequestUsecase().fetchAllUserByDepartment(
      onRequestSuccess: (List<CommonMasterModel> result){

        result.sort((a, b) => (a.name ?? '').toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));

        reporterList = result;
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception),
        );
      },
    );

    notifyListeners();
  }

  // Initialize values
  void initValues() {
    ticketNoController.clear();
    descriptionController.clear();
    clientController.clear();
    siteController.clear();
    buildingController.clear();
    floorController.clear();
    addressController.clear();
    typeController.clear();
    statusController.clear();
    categoryController.clear();
    priorityController.clear();
    engineerController.clear();
    reporterController.clear();
    closureDateController.clear();
    emailController.clear();
    phoneController.clear();

    selectedClient = null;
    selectedLocation = null;
    selectedType = null;
    selectedStatus = null;
    selectedCategory = null;
    selectedPriority = null;
    selectedEngineer = null;
    selectedReporter = null;
    selectedClosureDate = null;
    showSelectLocationButton = false;
    isEditMode = false;
    currentTicket = null;
    docAttachId = null;
    createdUserId = null;
    attachmentSeriesNo = "";
    tasks = [];
    selectedCity = null;
    cityController.clear();

    submittedTaskAttachments = [];
    notifyListeners();
    fetchClientLists();
    fetchCityLists();
    fetchServiceCategory();
    fetchServicePriority();
    fetchAllUserByDepartment();
    fetchUserByProjectDepartment();


  }

  CallTicketModel? currentTicket;
  String callTrackerStatus = "";
  void setParameters({Map<String, dynamic>? extra}) {
    if (extra != null && extra.containsKey('currentTicketDetails')) {
      currentTicket = extra['currentTicketDetails'];
      isEditMode = currentTicket != null;
      print("Last mode date --olokjh ${currentTicket?.lastModDate}");
      if(isEditMode){
        // currentTicker?.status??"" this is the flag
        initialize();
        fetchTaskDetails(ticketId: currentTicket?.id ?? 0);
      }
    }
  }


// Determines if the form is in view-only mode (Reviewed or Closed status)
  bool get isViewOnlyMode {
    if (!isEditMode || currentTicket == null) return false;
    final status = currentTicket?.status ?? "";
    return status == 'Reviewed' || status == 'Closed';
  }

// Determines if all fields are editable (Assignment Pending or Assigned status)
  bool get isFieldsEditable {
    if (!isEditMode || currentTicket == null) return true; // New mode - all editable
    final status = currentTicket?.status ?? "";
    return status == 'Assignment Pending' || status == 'Assigned';
  }

  // bool get isTargetClosureDateEditable {
  //   if (!isEditMode || currentTicket == null) return true; // New mode - editable
  //   final status = currentTicket?.status ?? "";
  //   // Editable for all statuses except Reviewed and Closed
  //   return status != 'Reviewed' && status != 'Closed';
  // }
// Assignment section is always editable (no status-based restrictions)
  bool get isTargetClosureDateEditable => true;




  void initialize() {
    // Fetch all required data first
    fetchClientLists();
    fetchCityLists();
    fetchServiceCategory();
    fetchServicePriority();
    fetchUserByProjectDepartment();

    // Populate fields if in edit mode
    if (isEditMode && currentTicket != null) {
      populateFieldsFromTicket(currentTicket!);
    }
  }

  // Populate form fields from existing ticket
  void populateFieldsFromTicket(CallTicketModel ticket) {
    // Set basic fields
    ticketNoController.text = ticket.ticketNo ?? "";
    descriptionController.text = ticket.description ?? "";

    // Set location fields
    siteController.text = ticket.site ?? "";
    buildingController.text = ticket.building ?? "";
    floorController.text = ticket.floor ?? "";
    addressController.text = ticket.address ?? "";

    // Set client (will be set when clientList is loaded)
    if (ticket.client != null && ticket.client!.isNotEmpty) {
      clientController.text = ticket.client!;
    }

    // Set city
    if (ticket.cityName != null && ticket.cityName!.isNotEmpty) {
      cityController.text = ticket.cityName!;
    }

    // Set category
    if (ticket.category != null && ticket.category!.isNotEmpty) {
      categoryController.text = ticket.category!;
      selectedCategory = ticket.category;
    }

    // Set priority
    if (ticket.priority != null && ticket.priority!.isNotEmpty) {
      priorityController.text = ticket.priority!;
      selectedPriority = ticket.priority;
    }

    // Set assigned engineer
    if (ticket.assignedUserForAdd != null && ticket.assignedUserForAdd!.isNotEmpty) {
      engineerController.text = ticket.assignedUserForAdd!;
      selectedEngineer = ticket.assignedUserForAdd;
    }

    // Set service reporter
    if (ticket.serviceReportUser != null && ticket.serviceReportUser!.isNotEmpty) {
      reporterController.text = ticket.serviceReportUser!;
      selectedReporter = ticket.serviceReportUser;
    }

    // Set target closure date
    if (ticket.targetClosureDateForAdd != null && ticket.targetClosureDateForAdd!.isNotEmpty) {
      try {
        selectedClosureDate = DateFormat('yyyy-MM-dd').parse(ticket.targetClosureDateForAdd!);
        closureDateController.text = "${selectedClosureDate?.day}/${selectedClosureDate?.month}/${selectedClosureDate?.year}";
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    notifyListeners();
  }

  // Helper method to set client from ticket once clientList is loaded
  void _setClientFromTicket() {
    if (currentTicket?.client != null && currentTicket!.client!.isNotEmpty && clientList.isNotEmpty) {
      try {
        final client = clientList.firstWhere(
              (c) => c.clientname.toLowerCase() == currentTicket!.client!.toLowerCase(),
        );
        selectedClient = client;
        clientController.text = client.clientname;
        showSelectLocationButton = true;
        emailController.text = selectedClient?.mailId??"";
        phoneController.text = selectedClient?.contactNo ?? "";

        // Fetch locations for this client
        fetchLocationAddress(client.id);
        notifyListeners();
      } catch (e) {
        print("Client not found in list: ${currentTicket!.client}");
      }
    }
  }

  // Helper method to set location from ticket once locationList is loaded
  void _setLocationFromTicket() {
    if (currentTicket != null && locationList.isNotEmpty) {
      try {
        // Try to find exact match
        final location = locationList.firstWhere(
              (l) =>
          l.site?.toLowerCase() == currentTicket!.site?.toLowerCase() &&
              l.building?.toLowerCase() == currentTicket!.building?.toLowerCase() &&
              l.floor?.toLowerCase() == currentTicket!.floor?.toLowerCase(),
        );
        selectedLocation = location;
        notifyListeners();
      } catch (e) {
        // Location not found in list, that's okay - fields are already populated
        print("Location not found in list");
      }
    }
  }

  // Helper method to set city from ticket once cityList is loaded
  void _setCityFromTicket() {
    print("City not found in list:");
    if (currentTicket?.cityName != null && currentTicket!.cityName!.isNotEmpty && cityList.isNotEmpty) {
      try {
        final city = cityList.firstWhere(
              (c) => c.cityname.toLowerCase() == currentTicket!.cityName!.toLowerCase(),
        );
        selectedCity = city;
        cityController.text = city.cityname;
        notifyListeners();
      } catch (e) {
        print("City not found in list: ${currentTicket!.cityName}");
      }
    }
  }

  // Set selected client
  void setSelectedClient(CommonMasterModel client) {
    selectedClient = client;
    clientController.text = client.clientname;
    if(selectedClient?.mailId != null){
      emailController.text = selectedClient?.mailId ?? "";
    }
    if(selectedClient?.contactNo != null){
      phoneController.text = selectedClient?.contactNo ?? "";
    }
    fetchLocationAddress(client.id);
  }
  // Set city client
  void setSelectedCity(CommonMasterModel city) {
    selectedCity = city;
    cityController.text = city.cityname;
    notifyListeners();
  }

  // Set selected location and auto-fill fields
  void setSelectedLocation(LocationModelAddresses location) {
    selectedLocation = location;
    siteController.text = location.site??"";
    buildingController.text = location.building??"";
    floorController.text = location.floor??"";
    addressController.text = location.address??"";
    notifyListeners();
  }

  // Get filtered locations for selected client
  List<LocationModelAddresses> getClientLocations() {
    if (selectedClient == null) return [];
    return locationList
        .where((location) => location.clientId == selectedClient!.id)
        .toList();
  }

  // Set selected category
  void setSelectedCategory(CommonMasterModel category) {
    selectedCategory = category.description;
    categoryController.text = category.description;
    notifyListeners();
  }

  // Set selected priority
  void setSelectedPriority(CommonMasterModel priority) {
    selectedPriority = priority.description;
    priorityController.text = priority.description;
    notifyListeners();
  }

  // Set selected engineer
  void setSelectedEngineer(CommonMasterModel engineer) {
    selectedEngineer = engineer.name;
    engineerController.text = engineer.name;
    syncTicketAssignmentToTasks();
    notifyListeners();
  }

  // Set selected reporter
  void setSelectedReporter(CommonMasterModel reporter) {
    selectedReporter = reporter.name;
    reporterController.text = reporter.name;
    notifyListeners();
  }

  // Set selected closure date
    void setSelectedClosureDate(DateTime date) {
      selectedClosureDate = date;
      closureDateController.text = "${date.day}/${date.month}/${date.year}";
      syncTicketAssignmentToTasks();
      notifyListeners();
    }

  void syncTicketAssignmentToTasks() {
    int? engineerId;
    if (selectedEngineer != null) {
      try {
        engineerId = engineerList.firstWhere((e) => e.name == selectedEngineer).id;
      } catch (e) {
        engineerId = null;
      }
    }

    String? targetDate;
    if (selectedClosureDate != null) {
      targetDate = DateFormat('yyyy-MM-dd').format(selectedClosureDate!);
    }

    for (var task in tasks) {
      if (engineerId != null) {
        task.assignedUserId = engineerId;
        task.assignedUser = selectedEngineer;
      }
      if (targetDate != null) {
        task.targetclosuredate = targetDate;
      }
    }
  }

  // Save service request (supports both create and update)
  Future<void> saveServiceRequest({
    required bool notifyClientYN,
    required VoidCallback onRequestSuccess,
    required Function(String) onRequestFailure,
  }) async {
    print("Tasks in provider -- $tasks");
    CommonMasterModel? engineer = engineerList
        .where((e) => e.name == selectedEngineer)
        .cast<CommonMasterModel?>()
        .firstWhere((e) => true, orElse: () => null);

    CommonMasterModel? reporter = reporterList
        .where((e) => e.name == selectedReporter)
        .cast<CommonMasterModel?>()
        .firstWhere((e) => true, orElse: () => null);

    final TicketModel ticketModel = TicketModel(
      id: isEditMode ? (currentTicket?.id ?? 0) : 0,
      client: clientController.text ?? "",
      sitename: siteController.text,
      building: buildingController.text,
      floor: floorController.text,
      address: addressController.text,
      description: descriptionController.text,
      categoryid: categoryList
          .firstWhere((e) => e.description == selectedCategory)
          .id,
      priorityid: priorityList
          .firstWhere((e) => e.description == selectedPriority)
          .id,
      targetclosuredate: selectedClosureDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedClosureDate!)
          : null,
      assigneduserid: engineer?.id,
      servicereportuserid: reporter?.id,
      lastmoddate: isEditMode ? currentTicket?.lastModDate : null,
      cityName: (selectedCity?.cityname??cityController.text)??"",
      serviceTasks: tasks,
      emailId: emailController.text.isNotEmpty ? emailController.text : null,
      phoneNo: phoneController.text.isNotEmpty ? phoneController.text : null,
      notifyClientYN: notifyClientYN ? "Y" : "N"
    );


    print("ticketModel___ ${isEditMode ? 'UPDATE' : 'CREATE'}: ${ticketModel.toString()}");

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    // Call create API
    AddServiceRequestUsecase().saveNewServiceRequest(
          ticketModel: ticketModel,
          onRequestSuccess: () {
            changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
            docAttachId = null;
            createdUserId = null;
            attachmentSeriesNo = "";
            onRequestSuccess();
          },
        onRequestFailure: (e) {
          onRequestFailure(e.toString());
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception:e ));
        } );

  }

  // Check for unsaved changes
  bool hasUnsavedChanges() {
    if (!isEditMode) {
      // For new tickets, check if any field is filled
      return ticketNoController.text.isNotEmpty ||
          descriptionController.text.isNotEmpty ||
          clientController.text.isNotEmpty ||
          siteController.text.isNotEmpty ||
          buildingController.text.isNotEmpty ||
          floorController.text.isNotEmpty ||
          addressController.text.isNotEmpty ||
          selectedType != null ||
          selectedStatus != null ||
          selectedCategory != null ||
          selectedPriority != null ||
          selectedEngineer != null ||
          selectedReporter != null;
    } else if (currentTicket != null) {
      // For edit mode, check if any field has changed from original
      return descriptionController.text != (currentTicket!.description ?? "") ||
          clientController.text != (currentTicket!.client ?? "") ||
          siteController.text != (currentTicket!.site ?? "") ||
          buildingController.text != (currentTicket!.building ?? "") ||
          floorController.text != (currentTicket!.floor ?? "") ||
          addressController.text != (currentTicket!.address ?? "") ||
          selectedCategory != currentTicket!.category ||
          selectedPriority != currentTicket!.priority ||
          selectedEngineer != currentTicket!.assignedUserForAdd ||
          selectedReporter != currentTicket!.serviceReportUser ||
          (selectedClosureDate != null
              ? DateFormat('yyyy-MM-dd').format(selectedClosureDate!)
              : null) != currentTicket!.targetClosureDateForAdd;
    }
    return false;
  }

  @override
  void dispose() {
    ticketNoController.dispose();
    descriptionController.dispose();
    clientController.dispose();
    siteController.dispose();
    buildingController.dispose();
    floorController.dispose();
    addressController.dispose();
    typeController.dispose();
    statusController.dispose();
    categoryController.dispose();
    priorityController.dispose();
    engineerController.dispose();
    reporterController.dispose();
    closureDateController.dispose();
    super.dispose();
  }

  void checkClientPresent(String client) {
    showSelectLocationButton = clientList.any((item) => item.name.toLowerCase() == client.toLowerCase());
    if(showSelectLocationButton == false){
      selectedLocation = null;
      siteController.clear();
      buildingController.clear();
      floorController.clear();
      addressController.clear();
    } else if(showSelectLocationButton){
      try {
        LocationModelAddresses location = locationList.firstWhere((item) => item.clientId ==
            clientList.firstWhere((item) => item.name.toLowerCase() == client.toLowerCase()).id);
        selectedLocation = location;
        siteController.text = location.site??"";
        buildingController.text = location.building??"";
        floorController.text = location.floor??"";
        addressController.text = location.address??"";
      } catch (e) {
        print("Location not found for client: $client");
      }
    }
    notifyListeners();
  }
  void checkIfClientIsPresent(String clientName) {
    if (clientName.isEmpty) {
      showSelectLocationButton = false;
      notifyListeners();
      return;
    }

    try {
      // Find the client in the list (case-insensitive)
      final client = clientList.firstWhere(
            (item) => item.clientname.toLowerCase() == clientName.toLowerCase(),
      );

      // Client found - show location button and fetch locations
      selectedClient = client;
      showSelectLocationButton = true;

      // Fetch locations for this client if not already loaded
      if (locationList.isEmpty || locationList.first.clientId != client.id) {
        fetchLocationAddress(client.id);
      }

    } catch (e) {
      // Client not found - hide location button and clear location fields
      showSelectLocationButton = false;
      selectedClient = null;
      selectedLocation = null;

      if (!isEditMode) {
        siteController.clear();
        buildingController.clear();
        floorController.clear();
        addressController.clear();
      }
    }

    notifyListeners();
  }

}