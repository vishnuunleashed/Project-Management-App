
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/add_support_request/add_support_request_provider.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/common_master_type_dropdown.dart';
import 'package:interior_design/presentation/view/common/common_multi_select_dialog.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/drop_down_select_multiselect.dart';
import 'package:interior_design/presentation/view/common/schedule_type_dialog.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';

class AddSupportRequestForm extends StatelessWidget {
  const AddSupportRequestForm({super.key,required this.deptKey, required this.textFieldFocusNode});
  final GlobalKey<DropdownSearchState> deptKey;
  final FocusNode textFieldFocusNode;
  @override
  Widget build(BuildContext context) {

    return BaseStatelessConsumer<AddSupportRequestProvider>(
        provider: addSupportRequestProvider,
        builder: (context, provider, ref) {
          final DateTime now = DateTime.now();
          final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
          return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  ),
              elevation: 0,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Column(spacing: 5,
                    children: [
                  BaseTextField(
                    focusNode: textFieldFocusNode,
                      hintText: "Add Request Points",
                      hintTextNeeded: true,
                      displayTitle: "Points",
                      maxLines: 3,
                      maxLength: 2000,
                      isRequiredField: true,
                      isEnabled:!provider.editSupport
                          ? false
                          : true,
                      customValidationMessage: "Please add Request Points",
                      controller: provider.pointsController
                  ),
                      Visibility(
                        visible: provider.editSupport && !provider.isFromCallTracker,
                        child: GestureDetector(
                            onTap: !provider.editSupport
                                ? null
                              : (){
                              textFieldFocusNode.unfocus();
                              showUserListDialog(context,
                                  userList: provider.owners,

                                  title: "Owners",
                                  onForward: (value) {
                                    provider.setSelectedOwner(value);
                                    GoRouter.of(context).pop();
                                  });
                            },
                            child: AbsorbPointer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Owner",style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 10,),
                                  TextFormField(
                                    style: Theme.of(context).textTheme.titleSmall,
                                    validator: (val){
                                      return (provider.selectedOwner == null) ? "Please select owner" :null;

                                    },
                                    controller: provider.supOwnerController,
                                    enabled: !provider.editSupport
                                      ? false
                                      : true,

                                    decoration: InputDecoration(
                                              suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                              // label: (provider.selectedOwner != null) ? Text("User"):null,
                                      hintText: "Owner",
                                        hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                                              labelStyle: Theme.of(context).textTheme.titleMedium,

                                              disabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.54,
                                                     ),
                                                  borderRadius: BorderRadius.circular(10)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.54,
                                                      color: Theme.of(context).colorScheme.primary),
                                                  borderRadius: BorderRadius.circular(10)),
                                              errorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 0.54, color: bayaInfraRedColor),
                                                  borderRadius: BorderRadius.circular(10)),
                                              focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 0.54, color: bayaInfraRedColor),
                                                  borderRadius: BorderRadius.circular(10)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 0.54,
                                                      color: provider.owners.isEmpty
                                                          ? Theme.of(context)
                                                          .disabledColor
                                                          .withValues(alpha: 0.5)
                                                          : Theme.of(context).colorScheme.primary),
                                                  borderRadius: BorderRadius.circular(10)),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ),
                      Visibility(
                        visible: provider.editSupport && provider.isFromCallTracker,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                              : (){
                            textFieldFocusNode.unfocus();
                            showSelectionDialog<EmployeeModel>(context,
                                items: provider.users,
                                getDisplayName: (user) => user.name,
                                title: "User",
                                searchHint: "Search user",
                                onSelect: (value) {
                                  provider.setSelectedUser(value);
                                  GoRouter.of(context).pop();
                                });
                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("User",style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10,),
                                TextFormField(

                                  validator: (val){
                                    return (provider.selectedUser == null) ? "Please select user" :null;

                                  },

                                  style: Theme.of(context).textTheme.titleSmall,
                                  controller: provider.userController,
                                  enabled: !provider.editSupport
                                      ? false
                                      : true,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                    // label: (provider.selectedOwner != null) ? Text("User"):null,
                                    hintText: "User",
                                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    labelStyle: Theme.of(context).textTheme.titleMedium,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.54,
                                        ),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: provider.users.isEmpty
                                                ? Theme.of(context)
                                                .disabledColor
                                                .withValues(alpha: 0.5)
                                                : Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: provider.editSupport,
                        child: AbsorbPointer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dependency department",style: Theme.of(context).textTheme.titleMedium,
                              ),
                              SizedBox(height: 10,),
                              TextFormField(
                                controller: provider.departmentController,

                                style: Theme.of(context).textTheme.titleSmall,
                                decoration: InputDecoration(
                                  hintText: "Dependency department",
                                  hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  labelStyle: Theme.of(context).textTheme.titleMedium,
                                  disabledBorder: OutlineInputBorder(
                                    borderSide:  BorderSide(width: 0.54,color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 0.54,
                                      color: provider.departmentList.isEmpty
                                          ? Theme.of(context).disabledColor.withValues(alpha: 0.5)
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: provider.isFromCallTracker,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                              : (){
                            commonMasterListDialog(context,
                                master:provider.callTrackerType,
                                title: "Service Tracker Type",
                                onForward: (value) {
                                  provider.setCallTrackerType(value);
                                  GoRouter.of(context).pop();
                                });

                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Task Type",style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10,),
                                TextFormField(

                                  validator: (val){
                                    return (provider.selectedCallTrackerType == null && provider.isFromCallTracker)
                                        ? "Please select type" :null;

                                  },

                                  style: Theme.of(context).textTheme.titleSmall,
                                  controller: provider.callTrackerTypeController,
                                  enabled: !provider.editSupport ? false : true,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                    // label: (provider.selectedOwner != null) ? Text("User"):null,
                                    hintText: "Task Type",
                                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    labelStyle: Theme.of(context).textTheme.titleMedium,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.54,
                                        ),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: provider.callTrackerType.isEmpty
                                                ? Theme.of(context)
                                                .disabledColor
                                                .withValues(alpha: 0.5)
                                                : Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: provider.editSupport && provider.isFromCallTracker,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                              : (){
                            textFieldFocusNode.unfocus();
                            // Using the generalized widget for owners
                            showMultiSelectDialog<EmployeeModel>(
                              context,
                              items: provider.users,
                              getId: (owner) => owner.name, // or owner.id if you have unique IDs
                              getDisplayName: (owner) => owner.name,
                              getSubtitle: (owner) => owner.department,
                              getImageUrl: (owner) => "",
                              onSubmit: (selectedIds) {
                                provider.selectCCMemberFromUsers(selectedIds);
                              },
                              initiallySelected: provider.observersString,
                              title: 'CC members',
                              searchHint: 'Search CC member',
                              submitButtonText: 'Ok',
                            );
                          },
                          child: AbsorbPointer(
                            child: Visibility(
                              visible: provider.editSupport,
                              child: AbsorbPointer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("CC members",style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: "CC members",


                                        enabled: !provider.editSupport ? false :true,
                                        hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        labelStyle: Theme.of(context).textTheme.titleMedium,
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 0.54,
                                            ),
                                            borderRadius: BorderRadius.circular(10)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 0.54,
                                                color: Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 0.54, color: bayaInfraRedColor),
                                            borderRadius: BorderRadius.circular(10)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 0.54, color: bayaInfraRedColor),
                                            borderRadius: BorderRadius.circular(10)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 0.54,
                                                color: provider.owners.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !provider.editSupport && provider.observersFromUser.isNotEmpty,
                        child:  Align(
                          alignment: Alignment.centerLeft,
                          child: Text("CC members",
                              textAlign: TextAlign.start,

                              style: Theme.of(context).textTheme.titleMedium
                          ),
                        ),
                      ),
                      Visibility(
                        visible: provider.observersFromUser.isNotEmpty,
                        child: SelectedUsersGridFromUser(selectedUsers: provider.observersFromUser,
                          showDelete: provider.editSupport,
                          onRemove: (item){
                            provider.removeObserverFromUser(item);
                          },
                        ),
                      ),
                      Visibility(
                        visible: !provider.isFromCallTracker,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                            : (){
                            textFieldFocusNode.unfocus();
                            showUserListDialogMultiSelect(context,
                                userList: provider.owners,
                                initiallySelected: provider.observersString,
                                title: "CC members",
                                onForward: (value) {
                                  provider.selectObservers(value);
                                });

                          },
                          child: Column(
                            children: [
                              Visibility(
                                visible: provider.editSupport,
                                child: AbsorbPointer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("CC members",style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      SizedBox(height: 10,),
                                      TextFormField(
                                        style: Theme.of(context).textTheme.titleSmall,
                                        decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                          // label: (provider.selectedOwner != null) ? Text("User"):null,
                                          hintText: "CC members",
                                          enabled: !provider.editSupport ? false :true,
                                          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).disabledColor,
                                          ),
                                          labelStyle: Theme.of(context).textTheme.titleMedium,
                                          disabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                width: 0.54,
                                              ),
                                              borderRadius: BorderRadius.circular(10)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 0.54,
                                                  color: Theme.of(context).colorScheme.primary),
                                              borderRadius: BorderRadius.circular(10)),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 0.54, color: bayaInfraRedColor),
                                              borderRadius: BorderRadius.circular(10)),
                                          focusedErrorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  width: 0.54, color: bayaInfraRedColor),
                                              borderRadius: BorderRadius.circular(10)),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 0.54,
                                                  color: provider.owners.isEmpty
                                                      ? Theme.of(context)
                                                      .disabledColor
                                                      .withValues(alpha: 0.5)
                                                      : Theme.of(context).colorScheme.primary),
                                              borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: !provider.editSupport && provider.observers.isNotEmpty,
                                  child:  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("CC members",
                                        textAlign: TextAlign.start,

                                        style: Theme.of(context).textTheme.titleMedium
                                    ),
                                  ),
                              ),
                              Visibility(
                                visible: provider.observers.isNotEmpty,
                                child: SelectedUsersGrid(selectedUsers: provider.observers,
                                  showDelete: provider.editSupport,
                                  onRemove: (item){
                                    provider.removeObserver(item);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),



                      Visibility(
                        visible: provider.isFromSchedules,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                              : (){
                            scheduleTypeListDialog(context,
                                  taskTypeList:provider.taskTypeDropdownList,
                                  title: "Schedule Type",
                                  onForward: (value) {
                                    provider.setSelectedTaskType(value);
                                    GoRouter.of(context).pop();
                                  });

                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Schedule Type",style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  style: Theme.of(context).textTheme.titleSmall,
                                  validator: (val){
                                    return (provider.selectedTaskType == null && provider.isFromSchedules) ? "Please select type" :null;

                                  },
                                  controller: provider.taskTypeController,
                                  enabled: !provider.editSupport ? false : true,
                                  decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                            // label: (provider.selectedOwner != null) ? Text("User"):null,
                                    hintText: "Schedule Type",
                                      hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).disabledColor,
                                      ),
                                            labelStyle: Theme.of(context).textTheme.titleMedium,
                                            disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 0.54,
                                                   ),
                                                borderRadius: BorderRadius.circular(10)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 0.54,
                                                    color: Theme.of(context).colorScheme.primary),
                                                borderRadius: BorderRadius.circular(10)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    width: 0.54, color: bayaInfraRedColor),
                                                borderRadius: BorderRadius.circular(10)),
                                            focusedErrorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    width: 0.54, color: bayaInfraRedColor),
                                                borderRadius: BorderRadius.circular(10)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 0.54,
                                                    color: provider.taskTypeDropdownList.isEmpty
                                                        ? Theme.of(context)
                                                        .disabledColor
                                                        .withValues(alpha: 0.5)
                                                        : Theme.of(context).colorScheme.primary),
                                                borderRadius: BorderRadius.circular(10)),
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: provider.isFromMaterialChart,
                        child: GestureDetector(
                          onTap: !provider.editSupport
                              ? null
                              : (){
                            commonMasterListDialog(context,
                                master:provider.materialSupportType,
                                title: "Material Support Type",
                                onForward: (value) {
                                  provider.setMaterialType(value);
                                  GoRouter.of(context).pop();
                                });

                          },
                          child: AbsorbPointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Material Support Type",style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  style: Theme.of(context).textTheme.titleSmall,
                                  validator: (val){
                                    return (provider.selectedMaterialType == null && provider.isFromMaterialChart)
                                        ? "Please select type" :null;

                                  },
                                  controller: provider.materialTypeController,
                                  enabled: !provider.editSupport ? false : true,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                    // label: (provider.selectedOwner != null) ? Text("User"):null,
                                    hintText: "Material Support Type",
                                    hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    labelStyle: Theme.of(context).textTheme.titleMedium,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.54,
                                        ),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54, color: bayaInfraRedColor),
                                        borderRadius: BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: provider.materialSupportType.isEmpty
                                                ? Theme.of(context)
                                                .disabledColor
                                                .withValues(alpha: 0.5)
                                                : Theme.of(context).colorScheme.primary),
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),


                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonDatesPicker(
                            label: "Target Closure Date",
                            firstDate: DateTime.now(),
                            lastDate: twoYearsLater,
                            onChange: (date) {
                              provider.changeReqClosureDate(date);
                            },
                            initialDate: provider.targetClosureDate),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: provider.isCritical,
                              activeColor: bayaInfraGraphBluePrimary,

                              side: WidgetStateBorderSide.resolveWith(
                                    (states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return const BorderSide(
                                      color: Colors.grey, // 👈 disabled border color
                                      width: 2,
                                    );
                                  }
                                  return null; // default border
                                },
                              ),
                              onChanged:!provider.editSupport
                                  ? null
                              :(val) {
                                provider.isCriticalMark();
                              },
                            ),
                            Text("Is Critical",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: !provider.editSupport
                                    ?bayaInfraGrey
                                :null,
                                ),),
                          ],
                        ),
                      ),
                    ],
                  )
                ]),
              ));
        });
  }
}

class SelectedUsersGrid extends StatelessWidget {
  final List<OwnerModel> selectedUsers;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedUsersGrid({
    super.key,
    required this.selectedUsers,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.13,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedUsers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final user = selectedUsers[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.30,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: user.profileurl ,
                              userName:  user.name ,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  user.profileurl ,
                            size: 50,
                            userName: user.name,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: showDelete,
                  child: Positioned(
                    top: 8,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemove(user.name),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class SelectedUsersGridFromUser extends StatelessWidget {
  final List<EmployeeModel> selectedUsers;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedUsersGridFromUser({
    super.key,
    required this.selectedUsers,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.13,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedUsers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final user = selectedUsers[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.30,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: "User",
                              userName:  user.name ,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  "",
                            size: 50,
                            userName: user.name,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: showDelete,
                  child: Positioned(
                    top: 8,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemove(user.name),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
