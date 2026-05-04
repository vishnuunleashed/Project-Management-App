import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/material_chart/brand_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/add_additional_material_provider.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/material_chart/add_additional_material/reason_type_dialog.dart';
import 'package:interior_design/presentation/view/material_chart/add_additional_material/uom_list_dialog.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';

class AddAdditionalMaterialScreen extends ConsumerStatefulWidget {
  AddAdditionalMaterialScreen({super.key});

  @override
  ConsumerState<AddAdditionalMaterialScreen> createState() =>
      _AddAdditionalMaterialScreenState();
}

class _AddAdditionalMaterialScreenState
    extends ConsumerState<AddAdditionalMaterialScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

  // Add FocusNodes
  final FocusNode workItemFocusNode = FocusNode();
  final FocusNode materialNameFocusNode = FocusNode();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode wastageFocusNode = FocusNode();
  final FocusNode reasonFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose FocusNodes
    workItemFocusNode.dispose();
    materialNameFocusNode.dispose();
    quantityFocusNode.dispose();
    wastageFocusNode.dispose();
    reasonFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldExit = await BaseDialog.show<bool>(
      context: context,
      title: "Confirm",
      message: "Unsaved changes will be lost. Continue?",
      actions: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: BaseElevatedButton(
                fontWeight: FontWeight.w700,
                borderRadius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () => GoRouter.of(context).pop(true), // exit
                text: "Yes",
              ),
            ),
            Expanded(
              child: BaseElevatedButton(
                fontWeight: FontWeight.w700,
                borderRadius: 24,
                backgroundColor: bayaInfraDisabledColor,
                onPressed: () => GoRouter.of(context).pop(false), // stay
                text: "No",
              ),
            )
          ],
        ),
      ],
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(
        NavigatorKey.navKey.currentState!.context);
    AdditionalMaterialChartProvider _additionalMaterialProvider =
    container.read(additionalMaterialChartProvider);

    return WillPopScope(
      onWillPop: () async {
        // final hasChanges = _additionalMaterialProvider.hasUnsavedChanges();
        // if (hasChanges) {
        //   return await _onWillPop(context);
        // }
        return true;
      },
      child: BaseView<AdditionalMaterialChartProvider>(
        provider: additionalMaterialChartProvider,
        appBar: CustomAppBar(
          shadowNeeded: true,
          title: const Text("Additional Material Indent"),
          onBack: (context) async {
            // final hasChanges = _additionalMaterialProvider.hasUnsavedChanges();
            // if (hasChanges) {
            //   return await _onWillPop(context);
            // }
            return true;
          },
        ),
        initState: (context, provider, ref) {
          provider.initValues();
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.setParameter(extra);

          UserRightsModel moduleList = ref
              .watch(homeProvider)
              .rightsLists
              .where((element) => element.optionCode == "MOB_ADDT_MAT_CHART")
              .first;

          provider.setOptionDtl(optionObj: moduleList);
        },
        dispose: (context) {
          // Cleanup if needed
        },
        builder: (context, provider, ref) {
          final DateTime now = DateTime.now();
          final DateTime twoYearsLater = DateTime(now.year + 2, now.month, now.day);
          return GestureDetector(
            onTap: () {
              // Unfocus all text fields when tapping outside
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque, // Important: makes the entire area tappable
            child: Column(
              children: [
                provider.projectDetailList.isEmpty
                    ? SizedBox(height: 0,)
                    : ProjectHeaderCard(
                    projectName: provider.projectDetailList.first.projectName??"",
                    endDate: provider.projectDetailList.first.endDate??DateTime.now(),
                    locationName: provider.projectDetailList.first.location??""
                ),
                Expanded(
                  child: Card(
                    color: Theme.of(context).cardColor,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                              child: Column(
                                children: [



                                  // Work Item
                                  BaseTextField(
                                    controller: provider.workItemController,
                                    hintText: "Enter work item",
                                    displayTitle: "Work item*",
                                    isRequiredField: true,
                                    customValidationMessage: 'Work item is required',
                                    focusNode: workItemFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(materialNameFocusNode);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Material Name
                                  BaseTextField(
                                    controller: provider.materialNameController,
                                    hintText: "Enter material name",
                                    displayTitle: "Material name*",
                                    isRequiredField: true,
                                    customValidationMessage: 'Material name is required',
                                    focusNode: materialNameFocusNode,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(quantityFocusNode);
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Quantity and Units Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BaseTextField(
                                          controller: provider.quantityController,
                                          hintText: "Enter quantity",
                                          displayTitle: "Quantity*",
                                          isRequiredField: true,
                                          textInputType: TextInputType.number,
                                          customValidationMessage: 'Quantity is required',
                                          focusNode: quantityFocusNode,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Visibility(
                                        visible:true,
                                        child: Expanded(
                                          child: GestureDetector(
                                            onTap: (){

                                              showUOMListDialog(context,
                                                  uomList: provider.uomList,
                                                  title: "Units",
                                                  onForward: (value) {
                                                    provider.setSelectedUom(value);
                                                    GoRouter.of(context).pop();
                                                    // After selecting unit, focus on wastage
                                                    Future.delayed(Duration(milliseconds: 300), () {
                                                      FocusScope.of(context).requestFocus(wastageFocusNode);
                                                    });
                                                  });
                                            },
                                            child: AbsorbPointer(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Units*",style: Theme.of(context).textTheme.titleMedium
                                                  ),
                                                  SizedBox(height: 10,),
                                                  TextFormField(
                                                    validator: (val){
                                                      return (provider.selectedUOM == null) ? "Please select unit" :null;

                                                    },
                                                    controller: provider.uomController,
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                    decoration: InputDecoration(
                                                      suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                                      // label: (provider.selectedOwner != null) ? Text("User"):null,
                                                      hintText: "Units",
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
                                                              color: provider.uomList.isEmpty
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
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BaseTextField(
                                          controller: provider.wastageController,
                                          hintText: "Wastage %",
                                          displayTitle: "Wastage %",
                                          isRequiredField: false,
                                          textInputType: TextInputType.number,
                                          focusNode: wastageFocusNode,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12,),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text("Required by date*",
                                                  style: Theme.of(context).textTheme.titleMedium
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            CommonDatesPicker(
                                                onChange: (date){
                                                  provider.changeDate(date);
                                                }, initialDate: provider.requiredDate),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),



                                  const SizedBox(height: 16),
                                  Visibility(
                                    visible: true,
                                    child: GestureDetector(
                                      onTap:  (){
                                        showSelectionDialog<BrandModel>(
                                          context,
                                          items: provider.brandType,
                                          getDisplayName: (brand) => brand.name??"",
                                          onSelect: (brand) {
                                            provider.setSelectedBrandType(brand);
                                            GoRouter.of(context).pop();
                                          },
                                          title: "Select brand",
                                          searchHint: "Search brand",
                                        );
                                      },
                                      child: AbsorbPointer(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Brand",style: Theme.of(context).textTheme.titleMedium?.copyWith(

                                            )
                                            ),
                                            SizedBox(height: 10,),
                                            TextFormField(
                                              controller: provider.brandTypeController,
                                              enabled: true,
                                              style: Theme.of(context).textTheme.titleSmall,
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                                // label: (provider.selectedOwner != null) ? Text("User"):null,
                                                hintText: "Brand",
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
                                                        color: provider.brandType.isEmpty
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
                                  const SizedBox(height: 16),

                                  // Reason Type
                                  Visibility(
                                    visible: true,
                                    child: GestureDetector(
                                      onTap:  (){
                                        showReasonTypeDialog(context,
                                            reasonType: provider.reasonType,
                                            title: "Reason type",
                                            onForward: (value) {
                                              provider.setSelectedReasonType(value);
                                              GoRouter.of(context).pop();
                                              // After selecting reason type, focus on reason details
                                              Future.delayed(Duration(milliseconds: 300), () {
                                                FocusScope.of(context).requestFocus(reasonFocusNode);
                                              });
                                            });
                                      },
                                      child: AbsorbPointer(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Reason type*",style: Theme.of(context).textTheme.titleMedium?.copyWith(

                                            )
                                            ),
                                            SizedBox(height: 10,),
                                            TextFormField(
                                              validator: (val){
                                                return (provider.selectedReasonType == null) ? "Please select reason type" :null;

                                              },
                                              style: Theme.of(context).textTheme.titleMedium,
                                              controller: provider.reasonTypeController,
                                              enabled: true,
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                                // label: (provider.selectedOwner != null) ? Text("User"):null,
                                                hintText: "Reason type",
                                                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Theme.of(context).disabledColor,

                                                ),
                                                labelStyle: Theme.of(context).textTheme.labelLarge,
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
                                                        color: provider.reasonType.isEmpty
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
                                  const SizedBox(height: 16),

                                  // Reason (Multi-line)
                                  BaseTextField(
                                    controller: provider.reasonController,
                                    hintText: "Enter reason details",
                                    displayTitle: "Reason details",
                                    maxLines: 4,
                                    focusNode: reasonFocusNode,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: BaseElevatedButton(
                          text: "Clear",
                          textColor: Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.grey,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          borderColor: Theme.of(context).textTheme.titleLarge?.color ??
                              Colors.grey,
                          fontWeight: FontWeight.w100,
                          elevation: 0,
                          onPressed: () {
                            provider.initValues();
                          },
                        ),
                      ),
                      Expanded(
                        child: BaseElevatedButton(
                          text: 'Save',
                          onPressed: () {
                            var formState = formKey.currentState;
                            if (formState!.validate()) {
                              _submitForm(context, provider,() {
                                FocusScope.of(context).requestFocus(workItemFocusNode);
                              },);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _submitForm(BuildContext context, AdditionalMaterialChartProvider provider,Function() onSuccess) {

    provider.saveMaterial(onRequestSuccess: () {
      onSaveDialog(
          context: context,
          title: "Success",
          transNo:"",
          icon: Icons.check_circle_outlined,
          iconColor: bayaInfraGreen,
          message: "New material added successfully",

          onClick: () {
            provider.initValues();

            GoRouter.of(context).pop();
            onSuccess();
          });
    }, onRequestFailure: (e) {
      onSaveDialog(
        transNo:"",
        context: context,
        title: "Failure",
        message: e.toString(),
        icon: Icons.error,
        iconColor: bayaInfraRed,
        onClick: () => GoRouter.of(context).pop(),
      );
    });

  }
  static void onSaveDialog({
    required BuildContext context,
    required String title,
    required String transNo,
    required IconData icon,
    required Color iconColor,
    required String message,
    required VoidCallback onClick,
  }) {
    BaseDialog.show(
        context: context,
        title: title,
        message: message,
        transNo: transNo,
        icon: Icon(icon,color: iconColor,size: 36,),
        actions: [
          BaseElevatedButton(
              fontWeight: FontWeight.w700,
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: onClick,
              text: "Ok")
        ]);
  }


}