/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/request/MOM/mom_save_model.dart';
import 'package:interior_design/data/model/response/MOM/action_item_model.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/usecase/MOM/add_mom_usecase.dart';


class AddMOMProvider extends BaseProvider {
  // ── Controllers ─────────────────────────────────────────────
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController externalAttendeesController =
      TextEditingController();
  final TextEditingController externalAttendeesEmailController =
      TextEditingController();
  final TextEditingController decisionTakenController = TextEditingController();
  final TextEditingController meetingTypeController = TextEditingController();

  // ── Dynamic Controllers (UI only) ────────────────────────────
  final List<TextEditingController> actionDescriptionControllers = [];
  final List<TextEditingController> actionOwnerControllers = [];

  List<OwnerModel> attendeesList = [];
  List<String> selAttendeesStr = [];
  List<OwnerModel> selAttendeesList = [];
  List<ActionItemModel> actionItems = [];
  List<CommonMasterModel> meetingTypesList = [];

  bool isEditMode = false;
  bool isFromActionItem = false;
  int? optionId;
  String? optionName;
  int? companyId;
  DateTime selectedDate = DateTime.now();
  OwnerModel? selectedOwner;
  CommonMasterModel? selectedMeetingType;

  int? momId;
  int? projectId;

  List<SupportRequestDtlModel> supportRequestList = [];
  int supStart = 0;
  int supLimit = 10;
  int? _currentActionItemId;
  ScrollController supScrollController = ScrollController();

  // ── Init ────────────────────────────────────────────────────
  void initValues() {
    projectId = null;
    optionId = null;
    momId = null;
    isEditMode = false;
    isFromActionItem = false;
    selectedMOM = null;
    optionName = null;
    attendeesList = [];
    selAttendeesStr = [];
    selAttendeesList = [];
    actionItems = [];
    supportRequestList = [];
    fetchMeetingTypes();
    notifyListeners();
  }

  void setNavigationParameter(Map<String, dynamic>? extra) {
    if (extra != null) {
      projectId = extra['projectId'];
      momId = extra['momId'];
      isEditMode = extra['editMode'] ?? false;
      isFromActionItem = extra['isFromActionItem'] ?? false;
      if (momId != null) {
        if(isFromActionItem){
          fetchEditModeMOMData(momId: momId ?? 0, isFromActionItem: true);
        }
        else{
        fetchOwners(isEditMode: true);
        }
      } else {
        fetchOwners();
      }
      notifyListeners();
    }
  }

  // ── Meeting Type ────────────────────────────────────────────
  void setMeetingType(CommonMasterModel meetingType) {
    selectedMeetingType = meetingType;
    meetingTypeController.text = meetingType.description;
    notifyListeners();
  }

  // ── Date ────────────────────────────────────────────────────
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // ── Attendees ───────────────────────────────────────────────
  void selectAttendees(List<String> selectedNames) {
    selAttendeesStr = selectedNames;
    selAttendeesList = attendeesList
        .where((owner) => selectedNames.contains(owner.name))
        .toList();
    notifyListeners();
  }

  void removeAttendees(String name) {
    selAttendeesStr.remove(name);
    selAttendeesList.removeWhere((user) => user.name == name);
    notifyListeners();
  }

  // ── Option ──────────────────────────────────────────────────
  Future<void> setOptionDtl({required UserRightsModel optionObj}) async {
    optionId = optionObj.rightsData[0].parentOptionId;
    optionName = optionObj.optionName ?? "";
    companyId = await BaseSecureStorage.getInt(BaseConstants.companyId);
    notifyListeners();
  }

  /// Fetch Owner
  Future<void> fetchOwners({bool isEditMode = false}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    AddMOMUseCase().fetchOwners(
      projectId: projectId ?? 0,
      onRequestSuccess: (result) {
        attendeesList = result;
        if (isEditMode) {
          fetchEditModeMOMData(momId: momId ?? 0);
        }
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        notifyListeners();
      },
      onRequestFailure: (e) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error, exception: e));
      },
    );
  }

  /// Fetch Meeting Types
  Future<void> fetchMeetingTypes() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddMOMUseCase().fetchMeetingTypes(
      onRequestSuccess: (result) {
        meetingTypesList = result;
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        notifyListeners();
      },
      onRequestFailure: (e) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error, exception: e));
      },
    );
  }

  // ── Action Items ────────────────────────────────────────────
  void addActionItem(ActionItemModel actionItem) {
    actionItems.add(actionItem);

    actionDescriptionControllers.add(
      TextEditingController(text: actionItem.description),
    );
    actionOwnerControllers.add(TextEditingController());

    notifyListeners();
  }

  void removeActionItem(int index) {
    actionItems.removeAt(index);
    actionDescriptionControllers[index].dispose();
    actionOwnerControllers[index].dispose();
    actionDescriptionControllers.removeAt(index);
    actionOwnerControllers.removeAt(index);
    notifyListeners();
  }

  void setActionItemDescription(String value, int index) {
    actionItems[index].description = value;
  }

  void setActionItemOwner(OwnerModel owner, int index) {
    actionOwnerControllers[index].text = owner.name;
    actionItems[index].selectedOwner = owner;
    notifyListeners();
  }

  // ── Save MOM ────────────────────────────────────────────────
  Future<void> saveMOM({required Function(int momHdrId) onSuccess}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    final model = MOMSaveModel(
      id: momId ?? 0,
      companyId: companyId ?? 0,
      optionId: optionId ?? 0,
      projectId: projectId ?? 0,
      meetingTitle: titleController.text,
      meetingTypeId: selectedMeetingType?.id,
      dateTime: selectedDate,
      location: locationController.text,
      discussionPoint: descriptionController.text,
      externalUsers: externalAttendeesController.text.replaceAll(" ", ""),
      externalUserEmails:
          externalAttendeesEmailController.text.replaceAll(" ", ""),
      decisionTaken: decisionTakenController.text,
      moMDtls: actionItems
          .where((item) => item.description.trim().isNotEmpty && item.description != "")
          .map((item) {
        return MomDetail(
          id: item.id,
          actionItem: item.description,
          ownerId: item.selectedOwner?.id,
          refOptionId: optionId ?? 0,
        );
      }).toList(),
      moMAttendeesDtls: selAttendeesList.map((e) {
        return MomAttendee(
          id: 0,
          userId: e.id ?? 0,
        );
      }).toList(),
    );

    AddMOMUseCase().saveMOM(
      momSaveModel: model,
      onRequestSuccess: ({required int momHdrId}) {
        clearMOMFields();
        onSuccess(momHdrId);

        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (e) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error, exception: e));
      },
    );
  }

  MOMListModel? selectedMOM;
  Future<void> fetchEditModeMOMData({required int momId, bool isFromActionItem = false}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    AddMOMUseCase().fetchEditModeMOMData(
      momId: momId,
      onRequestSuccess: (result) {
        if(isFromActionItem){
          selectedMOM = result.first;
        }
        else{
          final data = result.first;

          // ── Basic Fields ─────────────────────────────
          titleController.text = data.meetingTitle ?? "";
          locationController.text = data.location ?? "";
          descriptionController.text = data.discussionPoint ?? "";
          externalAttendeesController.text = data.externalUsers ?? "";
          externalAttendeesEmailController.text = data.externalUserEmails ?? "";
          decisionTakenController.text = data.decisionTaken ?? "";

          // ── Date ────────────────────────────────────
          if (data.dateTime != null && data.dateTime!.isNotEmpty) {
            selectedDate = DateTime.tryParse(data.dateTime!) ?? DateTime.now();
          }

          // ── Meeting Type ────────────────────────────
          selectedMeetingType = meetingTypesList
              .where((e) => e.id == data.meetingTypeId)
              .isNotEmpty
              ? meetingTypesList
              .firstWhere((e) => e.id == data.meetingTypeId)
              : null;

          meetingTypeController.text = selectedMeetingType?.description ?? "";

          // ── Attendees ───────────────────────────────
          final attendeesDtls = data.moMAttendeesDtls;

          selAttendeesList = attendeesList.where(
                (user) => attendeesDtls.any((a) => a.userId == user.id),
          ).toList();

          selAttendeesStr = selAttendeesList.map((e) => e.name).toList();

          // ── Action Items ────────────────────────────
          actionItems.clear();
          actionDescriptionControllers.clear();
          actionOwnerControllers.clear();

          for (var item in data.moMDtls) {
            OwnerModel? owner;

            final filtered = attendeesList.where((o) => o.id == item.ownerId);
            if (filtered.isNotEmpty) {
              owner = filtered.first;
            }

            final actionItem = ActionItemModel(
                id: item.id ?? 0,
                selectedOwner: owner,
                description: item.actionItem ?? "",
                observationList: item.observationDetails
            );

            actionItems.add(actionItem);

            actionDescriptionControllers.add(
              TextEditingController(text: item.actionItem ?? ""),
            );

            actionOwnerControllers.add(
              TextEditingController(text: owner?.name ?? ""),
            );
          }
        }


        notifyListeners();

        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus:
                LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }

  Future<void> sendMOMEmail({required Function() onSuccess, required int? momId}) async{
    changeLoadingStatus(
        loadingStatus:
        LoadingStatus(loader: Loader.loading));
    AddMOMUseCase().sendMOMEmail(
        momId: momId ?? 0,
        onRequestSuccess: (){
          onSuccess();
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });

  }

  // ── Clear All ───────────────────────────────────────────────
  void clearMOMFields() {
    momId = null;
    titleController.clear();
    locationController.clear();
    descriptionController.clear();
    externalAttendeesController.clear();
    externalAttendeesEmailController.clear();
    decisionTakenController.clear();
    meetingTypeController.clear();

    selectedDate = DateTime.now();
    selectedMeetingType = null;

    selAttendeesStr.clear();
    selAttendeesList.clear();

    for (final c in actionDescriptionControllers) {
      c.dispose();
    }
    for (final c in actionOwnerControllers) {
      c.dispose();
    }

    actionItems.clear();
    actionDescriptionControllers.clear();
    actionOwnerControllers.clear();

    selectedOwner = null;

    notifyListeners();
  }
  String userName = "";
  Future<void> getUserDetails() async{
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    notifyListeners();
  }

  void initPaginationController(int actionItemId) {
    _currentActionItemId = actionItemId;
    supStart = 0;
    supScrollController.removeListener(_onScroll);
    supScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!supScrollController.hasClients) return;

    final isNearBottom = supScrollController.position.pixels >=
        supScrollController.position.maxScrollExtent - 100;

    final totalRecords = supportRequestList.isNotEmpty
        ? (supportRequestList.first.totalRecords ?? 0)
        : 0;

    if (isNearBottom && totalRecords > supStart + supLimit) {
      supStart += supLimit;
      fetchSupportRequestBasedOnMOM(
        actionItemId: _currentActionItemId ?? 0,
        isLoadMore: true,         // ← pagination call
      );
    }
  }

  Future<void> fetchSupportRequestBasedOnMOM({
    required int actionItemId,
    bool isLoadMore = false,
    Function()? onSuccess,
  }) async {

    if (!isLoadMore) {
      supStart = 0;
      supportRequestList = [];
      _currentActionItemId = actionItemId;
      notifyListeners();
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    }

    AddMOMUseCase().fetchMOMBasedSupportRequests(
      actionItemId: actionItemId,
      start: supStart,
      limit: supLimit,
      onRequestSuccess: (result) {
        if (!isLoadMore) {
          supportRequestList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          onSuccess?.call();
        } else {
          supportRequestList += result;
        }
        notifyListeners();
      },
      onRequestFailure: (exception) {
        if (!isLoadMore) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        } else {
          supStart -= supLimit;
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  // ── Dispose ────────────────────────────────────────────────
  @override
  void dispose() {
    for (final c in actionDescriptionControllers) {
      c.dispose();
    }
    for (final c in actionOwnerControllers) {
      c.dispose();
    }
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    externalAttendeesController.dispose();
    externalAttendeesEmailController.dispose();
    decisionTakenController.dispose();
    meetingTypeController.dispose();
    super.dispose();
  }
}
