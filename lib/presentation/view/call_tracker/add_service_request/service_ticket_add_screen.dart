import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/add_service_request_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/add_service_request/widgets/location_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';

class ServiceTicketAddScreen extends ConsumerStatefulWidget {
  const ServiceTicketAddScreen({super.key});

  @override
  ConsumerState<ServiceTicketAddScreen> createState() =>
      ServiceTicketAddScreenState();
}

// AFTER
class ServiceTicketAddScreenState
    extends ConsumerState<ServiceTicketAddScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode _clientFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _siteFocusNode = FocusNode();
  final FocusNode _buildingFocusNode = FocusNode();
  final FocusNode _floorFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _clientFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _cityFocusNode.dispose();
    _siteFocusNode.dispose();
    _buildingFocusNode.dispose();
    _floorFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(addServiceRequestProvider);
    super.build(context); // <-- add this line

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ CLIENT & LOCATION SECTION ============
              Card(
                elevation: 0.5,

                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Client & Location",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      BaseTextField(
                        key: const ValueKey('client_field'),
                        displayTitle: "Client*",
                        controller: provider.clientController,
                        hintText: "Enter or select client",
                        isEnabled: provider.isFieldsEditable,
                        isRequiredField: true,
                        maxLength: 250,
                        focusNode: _clientFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_siteFocusNode);
                        },
                        onChanged: (client) {
                          provider.checkIfClientIsPresent(client);
                        },
                        customValidationMessage: 'Client is required',
                        suffixIcon: provider.isFieldsEditable
                            ? IconButton(
                          onPressed: () => _showClientDialog(context, provider),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Email & Phone Row ──
                      Row(
                        children: [
                          Expanded(
                            child: BaseTextField(
                              key: const ValueKey('email_field'),
                              displayTitle: "Email",
                              controller: provider.emailController,
                              hintText: "Enter email",
                              isEnabled: provider.isFieldsEditable,
                              isRequiredField: false,
                              maxLength: 254,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_phoneFocusNode);
                              },
                              customValidator: (value) {
                                if (value == null || value.isEmpty) return null;
                                final emailRegex = RegExp(
                                    r'^[\w.+\-]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]{2,}$');
                                return emailRegex.hasMatch(value)
                                    ? null
                                    : 'Enter a valid email';
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BaseTextField(
                              key: const ValueKey('phone_field'),
                              displayTitle: "Phone Number",
                              controller: provider.phoneController,
                              hintText: "Enter phone number",
                              isEnabled: provider.isFieldsEditable,
                              isRequiredField: false,
                              maxLength: 15,
                              focusNode: _phoneFocusNode,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_siteFocusNode);
                              },
                              customValidator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (value.length < 7) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Select Location button ──
                      if (provider.showSelectLocationButton &&
                          provider.isFieldsEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final clientLocations =
                                    provider.getClientLocations();
                                    if (clientLocations.isEmpty) {
                                      BaseSnackBar().show(
                                          message:
                                          'No locations available for this client');
                                      return;
                                    }
                                    showLocationSelectionDialog(
                                      context,
                                      locations: clientLocations,
                                      onSelect: (location) {
                                        provider.setSelectedLocation(location);
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.location_pin,
                                    color: bayaInfraWhiteColor,
                                  ),
                                  label: Text(
                                    "Select Location",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                      color: bayaInfraWhiteColor,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: bayaInfraWhiteColor,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      // Site & Building Row
                      Row(
                        children: [
                          Expanded(
                            child: BaseTextField(
                              key: const ValueKey('site_field'),
                              controller: provider.siteController,
                              hintText: "Enter site",
                              displayTitle: "Site*",
                              maxLength: 300,
                              isRequiredField: true,
                              isEnabled: provider.isFieldsEditable,
                              focusNode: _siteFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_buildingFocusNode);
                              },
                              customValidationMessage: 'Site is required',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BaseTextField(
                              key: const ValueKey('building_field'),
                              controller: provider.buildingController,
                              hintText: "Enter building",
                              displayTitle: "Building*",
                              maxLength: 300,
                              isRequiredField: true,
                              isEnabled: provider.isFieldsEditable,
                              focusNode: _buildingFocusNode,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_floorFocusNode);
                              },
                              customValidationMessage: 'Building is required',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      BaseTextField(
                        key: const ValueKey('floor_field'),
                        controller: provider.floorController,
                        hintText: "Enter floor",
                        displayTitle: "Floor*",
                        maxLength: 200,
                        isRequiredField: true,
                        isEnabled: provider.isFieldsEditable,
                        focusNode: _floorFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_addressFocusNode);
                        },
                        customValidationMessage: 'Floor is required',
                      ),
                      const SizedBox(height: 16),

                      BaseTextField(
                        key: const ValueKey('address_field'),
                        controller: provider.addressController,
                        hintText: "Enter address",
                        displayTitle: "Address",
                        maxLength: 500,
                        maxLines: 3,
                        isEnabled: provider.isFieldsEditable,
                        focusNode: _addressFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),

                      const SizedBox(height: 16),

                      BaseTextField(
                        key: const ValueKey('city_field'),
                        displayTitle: "City*",
                        controller: provider.cityController,
                        hintText: "Enter or select city",
                        isEnabled: provider.isFieldsEditable,
                        isRequiredField: true,
                        maxLength: 250,
                        focusNode: _cityFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_floorFocusNode);
                        },
                        customValidationMessage: 'City is required',
                        suffixIcon: provider.isFieldsEditable
                            ? IconButton(
                          onPressed: () => _showCityDialog(context, provider),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),


              // ============ TICKET DETAILS SECTION ============
              Card(
                elevation: 0.5,

                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ticket Details",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              context: context,
                              label: "Category*",
                              controller: provider.categoryController,
                              hintText: "Category",
                              isRequired: true,
                              selectedValue: provider.selectedCategory,
                              isEmpty: provider.categoryList.isEmpty,
                              isEditable: provider.isFieldsEditable,
                              onTap: () => _showCategoryDialog(context, provider),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              context: context,
                              label: "Priority*",
                              controller: provider.priorityController,
                              hintText: "Priority",
                              isRequired: true,
                              selectedValue: provider.selectedPriority,
                              isEmpty: provider.priorityList.isEmpty,
                              isEditable: provider.isFieldsEditable,
                              onTap: () => _showPriorityDialog(context, provider),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      BaseTextField(
                        key: const ValueKey('description_field'),
                        controller: provider.descriptionController,
                        hintText: "Enter description",
                        displayTitle: "Description*",
                        isRequiredField: true,
                        maxLines: 4,
                        maxLength: 2000,
                        isEnabled: provider.isFieldsEditable,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        customValidationMessage: 'Description is required',
                      ),
                      const SizedBox(height: 24),

                    ],
                  ),
                ),
              ),

              // ============ ASSIGNMENT SECTION ============
              Card(
                elevation: 0.5,

                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).cardColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assignment",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "Target Closure Date",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      const SizedBox(height: 10),

                      if (provider.isTargetClosureDateEditable)
                        CommonDatesPicker(
                          onChange: (date) {
                            provider.setSelectedClosureDate(date);
                          },
                          initialDate: provider.selectedClosureDate,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                provider.selectedClosureDate
                                    .toString()
                                    .split(' ')[0],
                                style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Engineer & Reporter Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              context: context,
                              label: "Task Owner",
                              controller: provider.engineerController,
                              hintText: "Select task owner",
                              isRequired: false,
                              selectedValue: provider.selectedEngineer,
                              isEmpty: provider.engineerList.isEmpty,
                              isEditable: true,
                              onTap: () => _showEngineerDialog(context, provider),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              context: context,
                              label: "Reviewer",
                              controller: provider.reporterController,
                              hintText: "Select reviewer",
                              isRequired: false,
                              selectedValue: provider.selectedReporter,
                              isEmpty: provider.reporterList.isEmpty,
                              isEditable: true,
                              onTap: () => _showReporterDialog(context, provider),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog helpers ──────────────────────────────────────────────────────────

  void _showClientDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialog<CommonMasterModel>(
      context,
      items: provider.clientList,
      getDisplayName: (client) => client.clientname,
      onSelect: (client) {
        provider.setSelectedClient(client);
        GoRouter.of(context).pop();
      },
      title: "Select Client",
      searchHint: "Search client",
    );
  }

  void _showCityDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialog<CommonMasterModel>(
      context,
      items: provider.cityList,
      getDisplayName: (city) => city.cityname,
      onSelect: (city) {
        provider.setSelectedCity(city);
        GoRouter.of(context).pop();
      },
      title: "Select City",
      searchHint: "Search city",
    );
  }

  void _showCategoryDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialog<CommonMasterModel>(
      context,
      items: provider.categoryList,
      getDisplayName: (category) => category.description,
      onSelect: (category) {
        provider.setSelectedCategory(category);
        GoRouter.of(context).pop();
        Future.delayed(const Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(_descriptionFocusNode);
        });
      },
      title: "Select Category",
      searchHint: "Search category",
    );
  }

  void _showPriorityDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialog<CommonMasterModel>(
      context,
      items: provider.priorityList,
      getDisplayName: (priority) => priority.description,
      onSelect: (priority) {
        provider.setSelectedPriority(priority);
        GoRouter.of(context).pop();
        Future.delayed(const Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(_descriptionFocusNode);
        });
      },
      title: "Select Priority",
      searchHint: "Search priority",
    );
  }

  void _showEngineerDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialogWithSubtitle<CommonMasterModel>(
      context,
      items: provider.engineerList,
      getDisplayName: (engineer) => engineer.name,
      getSubtitle: (engineer) => engineer.description,
      onSelect: (engineer) {
        provider.setSelectedEngineer(engineer);
        GoRouter.of(context).pop();
      },
      title: "Select Task Owner",
      searchHint: "Search task owner",
    );
  }

  void _showReporterDialog(
      BuildContext context, AddServiceRequestProvider provider) {
    showSelectionDialogWithSubtitle<CommonMasterModel>(
      context,
      items: provider.reporterList,
      getDisplayName: (reporter) => reporter.name,
      getSubtitle: (reporter) => reporter.description,
      onSelect: (reporter) {
        provider.setSelectedReporter(reporter);
        GoRouter.of(context).pop();
      },
      title: "Select Reviewer",
      searchHint: "Search reviewer",
    );
  }

  // ── Dropdown field builder ──────────────────────────────────────────────────

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isRequired,
    required String? selectedValue,
    required bool isEmpty,
    required bool isEditable,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: AbsorbPointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 10),
            TextFormField(
              enabled: isEditable,
              validator: (val) {
                return (selectedValue == null && isRequired)
                    ? "Please select $label"
                    : null;
              },
              controller: controller,
              style: Theme.of(context).textTheme.titleMedium,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                labelStyle: Theme.of(context).textTheme.titleMedium,
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.54,
                      color: Colors.grey.shade300,
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
                        color: isEmpty
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
    );
  }
}