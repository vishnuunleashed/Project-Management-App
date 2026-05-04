import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_dropdown_button_form_field.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/call_tracker_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/city_multi_selection.dart';
import 'package:interior_design/presentation/view/common/client_multi_select.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/engineer_multi_select.dart';
import 'package:interior_design/presentation/view/common/priority_multiselect.dart';
import 'package:interior_design/presentation/view/common/site_multi_selection.dart';
import 'package:interior_design/presentation/view/common/status_multi_select.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';

class CallTrackFilterBottomSheet extends StatefulWidget {
  final CallTrackerProvider provider;

  const CallTrackFilterBottomSheet({
    super.key,
    required this.provider,
  });

  @override
  State<CallTrackFilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<CallTrackFilterBottomSheet> {
  late TextEditingController _ticketNoController;

  @override
  void initState() {
    super.initState();

    _ticketNoController = TextEditingController(text: widget.provider.ticketNoFilter);
  }

  @override
  void dispose() {
    _ticketNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) {
    return BaseConsumer(
        provider: callTrackerProvider,
        builder: (context,provider,ref) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.dialogTheme.backgroundColor ?? theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Title
                // ── FIXED HEADER (outside scroll) ──────────────────
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 0),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Tickets',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => GoRouter.of(context).pop(),
                        icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: theme.dividerColor),
                SizedBox(height: 4,),


                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
// Handle b
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("Date From",
                                            style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 8),
                                        CommonDatesPicker(
                                          onChange: (date) => provider
                                              .changeDateFromFilter(date),
                                          initialDate:
                                          provider.dateFromFilter,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text("Date To",
                                            style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 8),
                                        CommonDatesPicker(
                                          onChange: (date) => provider
                                              .changeDateToFilter(date),
                                          initialDate: provider.dateToFilter,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8,),
                              BaseDropDownButtonFormField<TypeOptionModel>(
                                iconEnabledColor: Theme.of(context).colorScheme.primary,
                                fillColorNeeded: false,
                                label: "Type",
                                labelFontWeight: FontWeight.w600,
                                labelColor: Theme.of(context).textTheme.titleMedium?.color,
                                hintText: "All Tasks",
                                initialValue: provider.selectedType,
                                items: provider.typeOptions,
                                onChanged: (value) {
                                  provider.changeType(value!);
                                },
                                builder: (value) {
                                  return Text(value.name ?? "");
                                },
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap:  (){
                                  showStatusMultiSelectDialog(context,
                                      statusList:provider.statusList,
                                      initiallySelected: provider.selectedStatusString,
                                      title: "Select Status",
                                      onForward: (value) {
                                        provider.selectStatus(value);
                                      });

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Status",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        suffixIconColor: provider.statusList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedStatusList.isEmpty ? "All Statuses" : "Status",
                                        enabled: false,
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
                                                color: provider.statusList.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: provider.selectedStatusList.isNotEmpty,
                                      child: SelectedStatusGridFromUser(selectedStatus: provider.selectedStatusList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedStatus(item);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap:  (){
                                  showClientMultiSelectDialog(context,
                                      clientList:provider.clientList,
                                      initiallySelected: provider.selectedClientString,
                                      title: "Select Client",
                                      onForward: (value) {
                                        // provider.selectObservers(value);
                                        provider.selectClient(value);
                                      });

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Client",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        suffixIconColor: provider.clientList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedClientList.isEmpty ? "All Clients" : "Clients",
                                        enabled: false,
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
                                                color: provider.clientList.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: provider.selectedClientList.isNotEmpty,
                                      child: SelectedClientGridFromUser(selectedClient: provider.selectedClientList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedClient(item);
                                        },
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap:  (){
                                  showSiteMultiSelectDialog(context,
                                      siteList:provider.sitesList,
                                      initiallySelected: provider.selectedSitesString,
                                      title: "Select Site",
                                      onForward: (value) {
                                        provider.selectSites(value);
                                      });

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Site",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        suffixIconColor: provider.sitesList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedSitesList.isEmpty ? "All Sites" : "Sites",
                                        enabled: false,
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
                                                color: provider.statusList.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: provider.selectedSitesList.isNotEmpty,
                                      child: SelectedSitesGridFromUser(selectedSites: provider.selectedSitesList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedSites(item);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                              GestureDetector(
                                onTap:  (){
                                  showCityMultiSelectDialog(
                                      context,
                                      cityList: provider.cityList,
                                      title: "Select City",
                                      onForward:(value) {
                                        provider.selectCity(value);
                                      },
                                      initiallySelected: provider.selectedCityString);

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("City",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        suffixIconColor: provider.cityList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedCityList.isEmpty ? "All Cities" : "City",
                                        enabled: false,
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
                                                color: provider.selectedCityList.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),

                                    Visibility(
                                      visible: provider.selectedCityList.isNotEmpty,
                                      child: SelectedCityGridFromUser(selectedCity: provider.selectedCityList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedCity(item);
                                        },
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              /// priority
                              GestureDetector(
                                onTap:  (){
                                  showPriorityMultiSelectDialog(
                                      context,
                                      priorityList: provider.priorityList,
                                      title: "Select Priority",
                                      onForward:(value) {
                                        provider.selectPriority(value);
                                      },
                                      initiallySelected: provider.selectedPriorityString);

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Priority",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      style: Theme.of(context).textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        suffixIconColor: provider.cityList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedPriorityList.isEmpty ? "All Priority" : "Priority",
                                        enabled: false,
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
                                                color: provider.selectedPriorityList.isEmpty
                                                    ? Theme.of(context)
                                                    .disabledColor
                                                    .withValues(alpha: 0.5)
                                                    : Theme.of(context).colorScheme.primary),
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),

                                    Visibility(
                                      visible: provider.selectedPriorityList.isNotEmpty,
                                      child: SelectedPriorityGridFromUser(selectedPriority: provider.selectedPriorityList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedPriority(item);
                                        },
                                      ),
                                    ),

                                  ],
                                ),
                              ),


                              const SizedBox(height: 10),
                              // Ticket No. Filter
                              Text(
                                'Ticket No.',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ticketNoController,
                                style: theme.textTheme.titleSmall,
                                decoration: InputDecoration(
                                  hintText: 'Enter ticket number',
                                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                  ),
                                  suffixIcon: _ticketNoController.text.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _ticketNoController.clear();
                                      });
                                    },
                                  )
                                      : null,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),

                              SizedBox(height: 10,),

                              GestureDetector(
                                onTap:  (){
                                  showEngineerMultiSelectDialog(context,
                                      engineerList:provider.engineerList,
                                      initiallySelected: provider.selectedEngineerString,
                                      title: "Select Task Owner",
                                      onForward: (value) {
                                        // provider.selectObservers(value);
                                        provider.selectEngineer(value);
                                      });

                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Engineer",style: Theme.of(context).textTheme.titleMedium
                                    ),
                                    SizedBox(height: 10,),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        // label: (provider.selectedOwner != null) ? Text("User"):null,
                                        hintText: provider.selectedEngineerList.isEmpty ? "All Engineers" : "Engineers",
                                        suffixIconColor: provider.engineerList.isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                        enabled: false,
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
                                      ),
                                    ),
                                    Visibility(
                                      visible: provider.selectedEngineerList.isNotEmpty,
                                      child: SelectedEngineerGridFromUser(selectedEngineers: provider.selectedEngineerList,
                                        showDelete: true,
                                        onRemove: (item){
                                          provider.removeSelectedEngineer(item);
                                        },
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── FIXED FOOTER ──────────────────────────────────────
                Divider(height: 1, color: theme.dividerColor),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: BaseElevatedButton(
                          backgroundColor: bayaInfraDisabledColor,
                          onPressed: () {
                            provider.clearFilters();
                            GoRouter.of(context).pop();
                          },
                          text: 'Clear All',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BaseElevatedButton(
                          onPressed: () {
                            widget.provider.setTicketNoFilter(_ticketNoController.text);
                            provider.loadTickets(changeStart: true);
                            Navigator.pop(context);
                          },
                          text: 'Apply Filters',
                        ),
                      ),
                    ],
                  ),
                ),
                // ── END FIXED FOOTER ──────────────────────────────────
              ],
            ),
          );
        }
    );
  });
}
}
class SelectedStatusGridFromUser extends StatelessWidget {
  final List<StatusModel> selectedStatus;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedStatusGridFromUser({
    super.key,
    required this.selectedStatus,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedStatus.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final status = selectedStatus[index];

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status.description ?? "", // replace with your status label field
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall

                      ),
                      if (showDelete) const SizedBox(width: 4),
                      if (showDelete)
                        GestureDetector(
                          onTap: () => onRemove(status.description ?? ""),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
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
class SelectedClientGridFromUser extends StatelessWidget {
  final List<CommonMasterModel> selectedClient;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedClientGridFromUser({
    super.key,
    required this.selectedClient,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedClient.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final client = selectedClient[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.22,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: "Client",
                              userName:  client.clientname,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  "",
                            size: 32,
                            userName: client.clientname,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          client.clientname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
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
                      onTap: () => onRemove(client.clientname),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 10,
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

class SelectedSitesGridFromUser extends StatelessWidget {
  final List<SiteModel> selectedSites;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedSitesGridFromUser({
    super.key,
    required this.selectedSites,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedSites.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final sites = selectedSites[index];

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sites.siteName, // replace with your status label field
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      if (showDelete) const SizedBox(width: 4),
                      if (showDelete)
                        GestureDetector(
                          onTap: () => onRemove(sites.siteName),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
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

class SelectedPriorityGridFromUser extends StatelessWidget {
  final List<CommonMasterModel> selectedPriority;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedPriorityGridFromUser({
    super.key,
    required this.selectedPriority,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedPriority.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final priority = selectedPriority[index];

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        priority.description, // replace with your status label field
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      if (showDelete) const SizedBox(width: 4),
                      if (showDelete)
                        GestureDetector(
                          onTap: () => onRemove(priority.description),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
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

class SelectedCityGridFromUser extends StatelessWidget {
  final List<CommonMasterModel> selectedCity;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedCityGridFromUser({
    super.key,
    required this.selectedCity,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedCity.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final city = selectedCity[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.22,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: "Client",
                              userName:  city.cityname,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  "",
                            size: 32,
                            userName: city.cityname,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          city.cityname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
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
                      onTap: () => onRemove(city.cityname),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 10,
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

class SelectedEngineerGridFromUser extends StatelessWidget {
  final List<EngineerModel> selectedEngineers;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedEngineerGridFromUser({
    super.key,
    required this.selectedEngineers,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedEngineers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final engineer = selectedEngineers[index];

            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        engineer.name ?? "", // replace with your status label field
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      if (showDelete) const SizedBox(width: 4),
                      if (showDelete)
                        GestureDetector(
                          onTap: () => onRemove(engineer.name ?? ""),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
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