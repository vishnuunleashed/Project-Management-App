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
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_elevated_icon_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/MOM/action_item_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/presentation/provider/MOM/add_mom_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/MOM/partials/mom_support_bottom_sheet.dart';
import 'package:interior_design/presentation/view/common/common_datetime_picker.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/owner_multi_select.dart';
import 'package:interior_design/utils/routes.dart';

class AddMOMScreen extends ConsumerStatefulWidget {
  const AddMOMScreen({super.key});

  @override
  ConsumerState<AddMOMScreen> createState() => _AddMOMScreenState();
}

class _AddMOMScreenState extends ConsumerState<AddMOMScreen> with RouteAware {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _externalAttendeesFocusNode = FocusNode();
  final FocusNode _externalAttendeesEmailFocusNode = FocusNode();
  final FocusNode _decisionTakenFocusNode = FocusNode();

  @override
  void didPopNext() {
    Future.microtask(
      () async {
        var provider = ref.watch(addMOMProvider);
        if (provider.momId != null) {
          provider.fetchEditModeMOMData(momId: provider.momId ?? 0);
        }
      },
    );
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _locationFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _decisionTakenFocusNode.dispose();
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AddMOMProvider>(
      provider: addMOMProvider,
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.initValues();
        provider.setNavigationParameter(extra);
        final rightsLists = ref.watch(homeProvider).rightsLists;

        UserRightsModel? moduleList;

        if (rightsLists.isNotEmpty) {
          try {
            moduleList = rightsLists.firstWhere(
              (element) => element.optionCode == "MOB_MOM_ENTRY",
            );
          } catch (e) {
            moduleList = null;
          }
        }

        if (moduleList != null) {
          provider.setOptionDtl(optionObj: moduleList);
        }
      },
      appBar: CustomAppBar(
        title: BaseConsumer<AddMOMProvider>(
          provider: addMOMProvider,
          builder: (context, provider, ref) {
            return provider.isEditMode ? const Text("View MOM") : const Text("Add MOM");
          }
        ),
      ),
      builder: (context, provider, ref) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ================= MEETING DETAILS =================
                            /// Title
                            BaseTextField(
                              displayTitle: "Title*",
                              controller: provider.titleController,
                              hintText: "Enter meeting title",
                              isRequiredField: true,
                              readOnly: provider.isEditMode,
                              focusNode: _titleFocusNode,
                              textInputAction: TextInputAction.next,
                              customValidationMessage: "Please enter Title",
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_locationFocusNode);
                              },
                            ),
                            const SizedBox(height: 16),

                            /// Date
                            Text("Date",
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),

                            CommonDateTimePicker(
                              readOnly: provider.isEditMode,
                              isEnabled: !provider.isEditMode,
                              onChange: (date) {
                                provider.setSelectedDate(date);
                              },
                              initialDate: provider.selectedDate,
                            ),
                            SizedBox(
                              height: 16,
                            ),

                            /// Meeting Type
                            _buildDropdownField(
                              context: context,
                              label: "Meeting Type*",
                              controller: provider.meetingTypeController,
                              hintText: "Meeting Type",
                              isEmpty: provider.meetingTypesList.isEmpty,
                              readOnly: provider.isEditMode,
                              isEnabled: !provider.isEditMode,
                              onTap: () {
                                _showMeetingTypeDialog(context, provider);
                                FocusManager.instance.primaryFocus?.unfocus();
                              }

                            ),
                            const SizedBox(height: 16),

                            /// Location
                            BaseTextField(
                              displayTitle: "Location*",
                              controller: provider.locationController,
                              hintText: "Enter meeting location",
                              focusNode: _locationFocusNode,
                              isRequiredField: true,
                              textInputAction: TextInputAction.next,
                              customValidationMessage: "Please enter Location",
                              readOnly: provider.isEditMode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_externalAttendeesFocusNode);
                              },
                            ),
                            const SizedBox(height: 16),

                            ///Attendees
                            GestureDetector(
                              onTap: provider.isEditMode
                                  ? null
                                  : () => showOwnerMultiSelectDialog(context,
                                          ownersList: provider.attendeesList,
                                          initiallySelected:
                                              provider.selAttendeesStr,
                                          title: "Select attendees",
                                          onForward: (value) {
                                        provider.selectAttendees(value);
                                    FocusManager.instance.primaryFocus?.unfocus();
                                      }),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Attendees*",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                          Icons.keyboard_arrow_down_outlined),
                                      suffixIconColor:
                                          (provider.attendeesList.isEmpty ||
                                                  provider.isEditMode)
                                              ? Theme.of(context)
                                                  .disabledColor
                                                  .withValues(alpha: 0.5)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                      hintText:
                                          provider.selAttendeesList.isEmpty
                                              ? "All attendees"
                                              : "Attendees",
                                      enabled: false,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 0.54),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 0.54,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 0.54,
                                              color: bayaInfraRedColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 0.54,
                                              color: (provider.attendeesList
                                                          .isEmpty ||
                                                      provider.isEditMode)
                                                  ? Theme.of(context)
                                                      .disabledColor
                                                      .withValues(alpha: 0.5)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        provider.selAttendeesList.isNotEmpty,
                                    child: SelectedOwnerGrid(
                                      selectedOwners: provider.selAttendeesList,
                                      showDelete: !provider.isEditMode,
                                      onRemove: (item) =>
                                          provider.removeAttendees(item),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            (provider.selAttendeesList.isEmpty) ? const SizedBox(height: 16) : SizedBox.shrink(),

                            /// External attendees
                            if(!(provider.isEditMode && provider.externalAttendeesController.text.isEmpty))...[
                            BaseTextField(
                                displayTitle: "External Attendees",
                                controller: provider.externalAttendeesController,
                                hintText: "Enter external attendees",
                                maxLines: 1,
                                readOnly: provider.isEditMode,
                                focusNode: _externalAttendeesFocusNode,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      _externalAttendeesEmailFocusNode);
                                },
                            ),

                            const SizedBox(height: 16),
                            ],

                            /// External attendees email
                            if(!(provider.isEditMode && provider.externalAttendeesEmailController.text.isEmpty))...[
                            BaseTextField(
                              displayTitle: "External Attendees email",
                              controller:
                                  provider.externalAttendeesEmailController,
                              hintText: "Enter external attendees email",
                              maxLines: 1,
                              readOnly: provider.isEditMode,
                              focusNode: _externalAttendeesEmailFocusNode,
                              textInputAction: TextInputAction.next,
                              customValidator: validateEmails,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_descriptionFocusNode);
                              },
                            ),
                            const SizedBox(height: 16),
                            ],

                            /// Description
                            BaseTextField(
                              readOnly: provider.isEditMode,
                              displayTitle: "Discussion Point*",
                              controller: provider.descriptionController,
                              hintText: "Enter description",
                              maxLines: 4,
                              focusNode: _descriptionFocusNode,
                              isRequiredField: true,
                              textInputAction: TextInputAction.next,
                              customValidationMessage:
                                  "Please enter Discussion Point",
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_decisionTakenFocusNode);
                              },
                            ),

                            const SizedBox(height: 16),

                            ///Decision taken
                            BaseTextField(
                                displayTitle: "Decision Taken",
                                controller: provider.decisionTakenController,
                                hintText: "Enter decisions",
                                maxLines: 4,
                                readOnly: provider.isEditMode,
                                focusNode: _decisionTakenFocusNode,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                }),

                            /// ================= Action Item Section =================
                            Card(
                              margin: EdgeInsets.only(top: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Section header ───────────────────────────
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (provider.actionItems.isNotEmpty || !provider.isEditMode) ? Text(
                                          "ACTION ITEMS",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                        ) : Text(
                                          "No action items have been defined",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          ),
                                        ),
                                        if (provider.actionItems.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.25),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              "${provider.actionItems.length} item${provider.actionItems.length == 1 ? '' : 's'}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (provider.actionItems.isNotEmpty)
                                    const SizedBox(height: 10),

                                    // ── Action item cards ────────────────────────
                                    ...List.generate(
                                        provider.actionItems.length, (index) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.2),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // ── Card header ──────────────────────
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.06),
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(10)),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(
                                                            alpha: 0.15),
                                                    width: 0.5,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.12),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "${index + 1}",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "Action #${index + 1}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium
                                                            ?.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (provider
                                                          .actionItems.length >
                                                      1)
                                                    Visibility(
                                                      visible:
                                                          !provider.isEditMode,
                                                      child: InkWell(
                                                        onTap: () => provider
                                                            .removeActionItem(
                                                                index),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 12,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.7),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            /// Action Description
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  BaseTextField(
                                                    readOnly:provider.isEditMode,
                                                    displayTitle:
                                                        "Action Description*",
                                                    controller: provider
                                                            .actionDescriptionControllers[
                                                        index],
                                                    hintText:
                                                        "Describe the action to be taken…",
                                                    maxLines: 3,
                                                    onChanged: (value) {
                                                      provider
                                                          .setActionItemDescription(
                                                              value, index);
                                                    },
                                                  ),
                                                  const SizedBox(height: 10),

                                                  /// Assigned Owner Section
                                                  _buildDropdownField(
                                                    context: context,
                                                    label: "Assigned Owner",
                                                    isEnabled:
                                                        !provider.isEditMode,
                                                    readOnly: provider.isEditMode,
                                                    controller: provider
                                                            .actionOwnerControllers[
                                                        index],
                                                    hintText: "Select owner",
                                                    isEmpty: provider
                                                        .attendeesList.isEmpty,
                                                    onTap: () =>
                                                        _showOwnerDialog(
                                                            context,
                                                            provider,
                                                            index),
                                                  ),
                                                  const SizedBox(height: 10),

                                                  /// Add Observation & Add Support buttons
                                                  Visibility(
                                                    visible:
                                                        provider.isEditMode,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              BaseElevatedIconButton(
                                                            onPressed: () {
                                                              if (provider.actionItems[index].observationList.isEmpty) {
                                                                GoRouter.of(context).pushNamed(
                                                                  AppRoutes
                                                                      .addObservation,
                                                                  extra: {
                                                                    'projectId':
                                                                        provider
                                                                            .projectId,
                                                                    'observationPoint': provider
                                                                        .actionItems[
                                                                            index]
                                                                        .description,
                                                                    'owner': provider
                                                                        .actionItems[
                                                                            index]
                                                                        .selectedOwner
                                                                        ?.name,
                                                                    'isFromMOM':
                                                                        true,
                                                                    'actionItemId':
                                                                        provider
                                                                            .actionItems[index]
                                                                            .id,
                                                                  },
                                                                );
                                                              } else {
                                                                GoRouter.of(
                                                                        context)
                                                                    .push(
                                                                  AppRoutes
                                                                      .closeObservation,
                                                                  extra: {
                                                                    'observationId': provider
                                                                        .actionItems[
                                                                            index]
                                                                        .observationList
                                                                        .first
                                                                        .id,
                                                                    'projectId':
                                                                        provider
                                                                            .projectId,
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            fontSize: 12,
                                                            icon: (provider
                                                                    .actionItems[
                                                                        index]
                                                                    .observationList
                                                                    .isEmpty)
                                                                ? Icons.add
                                                                : Icons
                                                                    .visibility,
                                                            text: (provider
                                                                    .actionItems[
                                                                        index]
                                                                    .observationList
                                                                    .isEmpty)
                                                                ? "Add Observation"
                                                                : "View Observation",
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child:
                                                              BaseElevatedIconButton(
                                                            onPressed: () {
                                                              provider.fetchSupportRequestBasedOnMOM(actionItemId: provider.actionItems[index].id,
                                                                onSuccess: () {
                                                                if(provider.supportRequestList.isNotEmpty) {
                                                                  provider
                                                                      .initPaginationController(
                                                                      provider
                                                                          .actionItems[index]
                                                                          .id);
                                                                  MOMSupportRequestBottomSheet
                                                                      .show(
                                                                    context,
                                                                    actionItem: provider
                                                                        .actionItems[index]
                                                                        .description,
                                                                    ownerName: provider
                                                                        .actionItems[index]
                                                                        .selectedOwner
                                                                        ?.name,
                                                                    projectId: provider
                                                                        .projectId,
                                                                    actionItemId: provider
                                                                        .actionItems[index]
                                                                        .id,
                                                                  );
                                                                }
                                                                else {
                                                                  GoRouter
                                                                      .of(
                                                                      context)
                                                                      .pushNamed(
                                                                    AppRoutes
                                                                        .addSupportRequest,
                                                                    extra: {
                                                                      'projectId': provider
                                                                          .projectId ??
                                                                          0,
                                                                      'supportRequestPoints': provider
                                                                          .actionItems[index]
                                                                          .description,
                                                                      'owner': provider
                                                                          .actionItems[index]
                                                                          .selectedOwner
                                                                          ?.name,
                                                                      'isFromMOM': true,
                                                                      'actionItemId': provider
                                                                          .actionItems[index]
                                                                          .id
                                                                    },
                                                                  );
                                                                }
                                                                },
                                                              );
                                                            },
                                                            icon: Icons.add,
                                                            text: "Add Support",
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    /// Add Action Item button
                                    const SizedBox(height: 4),
                                    Visibility(
                                      visible: !provider.isEditMode,
                                      child: InkWell(
                                        onTap: () {
                                          provider.addActionItem(
                                            ActionItemModel(
                                              id: 0,
                                              description: "",
                                              selectedOwner: null,
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(8),
                                          dashPattern: const [6, 4],
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.4),
                                          strokeWidth: 0.8,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(
                                                            alpha: 0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 12,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Add action item",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ]),
                    ),
                  ),
                ),
              )),
            ),

            /// Save and Clear button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: (!provider.isEditMode)
                  ? Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: BaseElevatedButton(
                              text: "Clear",
                              textColor: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color ??
                                  Colors.grey,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              borderColor: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color ??
                                  Colors.grey,
                              elevation: 0,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                provider.clearMOMFields();
                              }),
                        ),
                        Expanded(
                          child: BaseElevatedButton(
                              text: 'Save',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {

                                  /// Attendees validation
                                  if (provider.selAttendeesList.isEmpty) {
                                    BaseSnackBar()
                                        .show(message: "Attendees is required");
                                    return;
                                  }
                                  else if(provider.selectedMeetingType == null){
                                    BaseSnackBar()
                                        .show(message: "Meeting Type is required");
                                    return;
                                  }
                                  FocusScope.of(context).unfocus();
                                  provider.saveMOM(onSuccess: (momHdrId) {
                                    FocusScope.of(context).unfocus();
                                    BaseDialog.show(
                                        barrierDismissible: false,
                                        context: context,
                                        title: "Success",
                                        message: "MOM saved successfully",
                                        icon: Icon(
                                          Icons.check_circle_outline,
                                          color: bayaInfraGreen,
                                          size: 36,
                                        ),
                                        actions: [
                                          BaseElevatedButton(
                                            borderRadius: 24,
                                            onPressed: () {
                                              GoRouter.of(context).pop();
                                              BaseDialog.show(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  title: "Notify Attendees",
                                                  message:
                                                      'Do you want to send an email notification to attendees?',
                                                  icon: Icon(
                                                      Icons.email_outlined),
                                                  actions: [
                                                    Row(
                                                      spacing: 8,
                                                      children: [
                                                        Expanded(
                                                            child:
                                                                BaseElevatedButton(
                                                          borderRadius: 24,
                                                          onPressed: () {
                                                            GoRouter.of(context)
                                                                .pop();
                                                          },
                                                          backgroundColor:
                                                              bayaInfraDisabledColor,
                                                          text: "No",
                                                        )),
                                                        Expanded(
                                                          child:
                                                              BaseElevatedButton(
                                                            borderRadius: 24,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                            text: "Yes",
                                                            onPressed: () {
                                                              GoRouter.of(
                                                                      context)
                                                                  .pop();
                                                              provider
                                                                  .sendMOMEmail(
                                                                      momId:
                                                                          momHdrId,
                                                                      onSuccess:
                                                                          () {
                                                                        BaseDialog.show(
                                                                            barrierDismissible: false,
                                                                            context: context,
                                                                            title: "Success",
                                                                            message: "Email invitation sent successfully",
                                                                            icon: Icon(
                                                                              Icons.check_circle_outline,
                                                                              color: bayaInfraGreen,
                                                                              size: 36,
                                                                            ),
                                                                            actions: [
                                                                              BaseElevatedButton(
                                                                                borderRadius: 24,
                                                                                onPressed: () {
                                                                                  GoRouter.of(context).pop();
                                                                                },
                                                                                backgroundColor: Theme.of(context).primaryColor,
                                                                                text: "Ok",
                                                                              ),
                                                                            ]);
                                                                      });
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ]);
                                            },
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            text: "Ok",
                                          ),
                                        ]);
                                  });
                                }
                                else{
                                  WidgetsBinding.instance.addPostFrameCallback((_){
                                    if(provider.titleController.text.isEmpty){
                                      _titleFocusNode.requestFocus();
                                    }
                                    else if(provider.locationController.text.isEmpty){
                                      _locationFocusNode.requestFocus();
                                    }
                                    else if(provider.descriptionController.text.isEmpty){
                                    _descriptionFocusNode.requestFocus();
                                    }
                                  });

                                }
                              }),
                        ),
                      ],
                    )
                  : BaseElevatedButton(
                      text: 'Send Email',
                      onPressed: () {
                        BaseDialog.show(
                            barrierDismissible: false,
                            context: context,
                            title: "Notify Attendees",
                            message:
                                'Do you want to send an email notification to attendees?',
                            icon: Icon(Icons.email_outlined),
                            actions: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(
                                      child: BaseElevatedButton(
                                    borderRadius: 24,
                                    onPressed: () {
                                      GoRouter.of(context).pop();
                                    },
                                    backgroundColor: bayaInfraDisabledColor,
                                    text: "No",
                                  )),
                                  Expanded(
                                    child: BaseElevatedButton(
                                      borderRadius: 24,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      text: "Yes",
                                      onPressed: () {
                                        GoRouter.of(context).pop();
                                        provider.sendMOMEmail(
                                            momId: provider.momId,
                                            onSuccess: () {
                                              BaseDialog.show(
                                                  context: context,
                                                  title: "Success",
                                                  message:
                                                      "Email invitation sent successfully",
                                                  icon: Icon(
                                                    Icons.check_circle_outline,
                                                    color: bayaInfraGreen,
                                                    size: 36,
                                                  ),
                                                  actions: [
                                                    BaseElevatedButton(
                                                      borderRadius: 24,
                                                      onPressed: () {
                                                        GoRouter.of(context)
                                                            .pop();
                                                      },
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      text: "Ok",
                                                    ),
                                                  ]);
                                            });
                                      },
                                    ),
                                  )
                                ],
                              )
                            ]);
                      }),
            ),
          ],
        );
      },
    );
  }
}

void _showOwnerDialog(
    BuildContext context, AddMOMProvider provider, int index) {
  showSelectionDialog<OwnerModel>(
    context,
    items: provider.attendeesList,
    getDisplayName: (item) => item.name,
    onSelect: (value) {
      provider.setActionItemOwner(value, index);
      GoRouter.of(context).pop();
    },
  );
}

void _showMeetingTypeDialog(BuildContext context, AddMOMProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.meetingTypesList,
    getDisplayName: (item) => item.description,
    onSelect: (value) {

      provider.setMeetingType(value);
      GoRouter.of(context).pop();
    },
  );
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  return emailRegex.hasMatch(email);
}

String? validateEmails(String? value) {
  print("Validator called __");
  if (value == null || value.trim().isEmpty) return null;

  final emails = value.split(',');

  for (var email in emails) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) continue;

    if (!isValidEmail(trimmedEmail)) {
      return "Invalid email: $trimmedEmail";
    }
  }

  return null;
}

class SelectedOwnerGrid extends StatelessWidget {
  final List<OwnerModel> selectedOwners;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedOwnerGrid({
    super.key,
    required this.selectedOwners,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedOwners.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final owner = selectedOwners[index];

            return Stack(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        owner.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (showDelete) const SizedBox(width: 4),
                      if (showDelete)
                        GestureDetector(
                          onTap: () => onRemove(owner.name),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(
                              Icons.close,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required bool isEmpty,
  required VoidCallback onTap,
  required bool isEnabled,
  required bool readOnly,

}) {
  final theme = Theme.of(context);

  return GestureDetector(
    onTap: isEnabled ? onTap : null,
    child: AbsorbPointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          TextFormField(
            readOnly: readOnly,
            controller: controller,
            enabled: isEnabled,
            style: theme.textTheme.titleSmall?.copyWith(
              color: (isEnabled || readOnly)
                  ? theme.textTheme.bodyLarge?.color
                  : theme.disabledColor,
            ),
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_outlined,
                color:
                    isEnabled ? theme.colorScheme.primary : theme.disabledColor,
              ),
              hintText: hintText,
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
              labelStyle: theme.textTheme.titleMedium,
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.54,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.54,
                  color: (isEmpty)
                      ? theme.disabledColor.withOpacity(0.5)
                      : theme.colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.54,
                  color: theme.colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 0.54, color: bayaInfraRedColor),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 0.54, color: bayaInfraRedColor),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
