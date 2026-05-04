/*------------------------------------------------------------------------------
AUTHOR		    : Favas k
CREATED DATE	: 09/08/2025
PURPOSE		    :
MODULE/TOPIC	: IN0010-25
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'dart:io';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/presentation/provider/add_observation/add_observation_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/presentation/view/common/user_list_dialog.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';
import 'package:interior_design/utils/routes.dart';

class AddObservationsScreen extends StatelessWidget {
  const AddObservationsScreen({super.key});

  static final _formKey = GlobalKey<FormState>();
  static final _textFieldFocusNode = FocusNode();

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
                borderRadius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () => GoRouter.of(context).pop(true), // exit
                text:"Yes",
              ),
            ),
            Expanded(
              child: BaseElevatedButton(
                borderRadius: 24,
                backgroundColor: bayaInfraDisabledColor,
                onPressed: () => GoRouter.of(context).pop(false), // stay
                text:"No",
              ),
            ),
          ],
        ),
      ],
    );

    return shouldExit ?? false; // false = don't pop
  }

  @override
  Widget build(BuildContext context) {

    final container = ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context);
    AddObservationProvider _addObservationProvider = container.read(addObservationProvider);
    return WillPopScope(
      onWillPop: () async {
        final hasRemarks = _addObservationProvider.observationPointsController.text.isNotEmpty;

        if (hasRemarks) {
          return await _onWillPop(context);
        }
        return true;
      },
      child: BaseView<AddObservationProvider>(
        provider: addObservationProvider,
        initState: (context, provider, ref) async {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.initValues();
          provider.setParameter(extra);


          if(extra == null  || extra["observationList"] == null){
            final List<File>? files = await MediaServiceWithCrop.instance.pickImage(
                context,enableCrop: true,
                enableMultiSelect: true,
                enableDoodling: true
            );
            if (files != null) {
              provider.uploadImageFile(files);
            }
          }
        UserRightsModel moduleList = ref
            .watch(homeProvider)
            .rightsLists
            .where((element) => element.optionCode == "MOB_ADD_OBSERVATION")
            .first;

          provider.setOptionDtl(optionObj: moduleList);

        },
        appBar: CustomAppBar(
          title: Consumer(builder: (context, ref, __) {
            final p = ref.watch(addObservationProvider);
            final title = p.optionName.isNotEmpty ? p.optionName : 'Add Observations';
            return Text(title);
          }),
          onBack: (context) async {
            final hasRemarks = _addObservationProvider.observationPointsController.text.isNotEmpty;
            if (hasRemarks) {
              return await _onWillPop(context); // show confirm
            }
            return true; // exit directly
          },
        ),
        builder: (context, provider, ref) {
          final homeProviderRef = ref.watch(homeProvider.notifier);
          final ownerKey = GlobalKey<DropdownSearchState<OwnerModel>>();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Add bottom padding to prevent overlap with Floating Action Button
                  padding: const EdgeInsets.only(bottom: 70), //
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.projectDetailList.isEmpty
                          ? SizedBox(height: 0,)
                          : ProjectHeaderCard(
                          projectName: provider.projectDetailList.first.projectName??"",
                          endDate: provider.projectDetailList.first.endDate??DateTime.now(),
                          locationName: provider.projectDetailList.first.location??""
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(children: [
                              // Points Section
                              BaseTextField(
                                controller: provider.observationPointsController,
                                focusNode: _textFieldFocusNode,
                                displayTitle: "Points",
                                hintText: 'Add observation points',
                                isRequiredField: true,
                                hintTextNeeded: true,
                                maxLength: 2000,
                                maxLines: 3,


                            ),
                            const SizedBox(height: 12),
                            // Owners Section
                              GestureDetector(
                                onTap: (){
                                  _textFieldFocusNode.unfocus();
                                  showUserListDialog(
                                    title: "Owners",
                                      context,
                                      userList: provider.owners,
                                      // names: provider.namesFromOwnerModel,
                                      onForward: (value){

                                        provider.setSelectedOwner(value);

                                        GoRouter.of(context).pop();
                                      });
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    // validator: (val){
                                    //   return (provider.selectedOwner == null) ? "Please select owner" : null;
                                    // },
                                    controller: provider.obsOwnerController,
                                    style: Theme.of(context).textTheme.titleSmall,
                                    decoration:  InputDecoration(
                                        suffixIcon: Icon(Icons.keyboard_arrow_down_outlined),
                                        // label: (provider.selectedOwner != null) ? Text("Owner"):null,
                                        hintText: "Owner",
                                        hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        labelStyle: Theme.of(context).textTheme.titleMedium,
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 0.54,),
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

                                    onTap: (){
                                    },

                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                              // Attachments list (upload moved to FloatingActionButton)
                              if (provider.attachmentUrl.isNotEmpty) ...[
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Images (${provider.attachmentUrl.length})", style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                      color: Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.color,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (provider.attachmentUrl.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.15,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          // slot width = 1/3 of total width
                                          final double slotWidth = constraints.maxWidth / 3;

                                          final urls = provider.attachmentUrl.map((e) => e.url).toList();

                                          final firstThree = urls.length > 3 ? urls.sublist(0, 3) : urls;
                                          return Row(
                                            children: List.generate(3, (i) {
                                              if (i < firstThree.length) {
                                                return SizedBox(
                                                  width: slotWidth,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _openImageViewer(context, provider, i);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(6),
                                                      child: _buildImageContainer(firstThree[i], context,i,provider),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // empty slot
                                                return SizedBox(
                                                  width: slotWidth,
                                                );
                                              }
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],


                              ],
                            ])
                          )
                        )
                      )
                    ]
                  )
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: BaseElevatedButton(
                        text: "Clear",
                        textColor: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.color ?? Colors.grey,
                        backgroundColor: Theme
                            .of(context)
                            .scaffoldBackgroundColor,
                        borderColor: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.color ?? Colors.grey,
                        onPressed: () {
                          provider.initValues();
                          _formKey.currentState!.reset();
                          ownerKey.currentState!.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    provider.observationList.isNotEmpty
                        ? Expanded(
                        child: BaseElevatedButton(
                            text: "Update",
                            onPressed: () {

                              if(provider.selectedOwner == null){
                                BaseSnackBar().show(message: "Select an owner");
                                return;
                              }
                              if (_formKey.currentState!.validate()) {
                                _submitFormUpdateStatus(context, provider,homeProviderRef,provider.projectDetailList.first.projectId??0);
                                _textFieldFocusNode.unfocus();

                              }
                            }
                        )
                    )
                        : Expanded(
                      child: BaseElevatedButton(
                        text: "Submit",
                        onPressed: () {
                          // if (provider.images.isEmpty) {
                          //   BaseSnackBar().show(
                          //     message: 'Please attach at least one image.',
                          //   );
                          //   _formKey.currentState!.validate();
                          //   return;
                          // }
                          if (_formKey.currentState!.validate()) {
                            _submitForm(context, provider,homeProviderRef,provider.projectDetailList.first.projectId??0);
                            _textFieldFocusNode.unfocus();

                          }
                        }
                      )
                    )
                  ]
                )
              )
            ]
          );
        },
        virtualFloatingActionButton: Consumer(
          builder: (context, ref, __) {
            final p = ref.watch(addObservationProvider);
            return Visibility(
              visible: p.observationList.isEmpty,
              child: Align(
                heightFactor: 3,
                widthFactor: 1,
                child: FloatingActionButton(
                  // backgroundColor: bayaInfraLightGreenColor,
                  backgroundColor: Theme.of(context).primaryColor,

                  elevation: 0,
                  onPressed: () async {
                    final List<File>? files = await MediaServiceWithCrop.instance.pickImage(
                        context,enableCrop: true,
                        enableMultiSelect: true,
                      enableDoodling: true

                    );
                    if (files != null) {
                      p.uploadImageFile(files);
                    }
                  },
                  tooltip: 'Add image',
                  child: Icon(Icons.camera_alt, color: Colors.white,)
                )
              ),
            );
          }
        )
      ),
    );
  }
  Widget _buildImageContainer(String? imageUrl, BuildContext context,int index,AddObservationProvider provider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        elevation: 0.5,
        color: Theme.of(context).cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: (){
              GoRouter.of(context).pushNamed(
                AppRoutes.imageGridObsScreen,
                extra: {
                  "addObservationProvider": provider
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl??"",
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(context),
              errorWidget: (context, url, error) => _buildPlaceholder(context),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPlaceholder(BuildContext context) {
    return  SizedBox(
      height: MediaQuery.of(context).size.height*0.15,
      child: Center(
        child: Icon(
          Icons.attach_file,
          size: 32,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }



// Generic Success/Failure Dialog
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
              borderRadius: 24,
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: onClick,
              text: "Ok")
        ]);
  }




  static void _submitFormUpdateStatus(BuildContext context, AddObservationProvider provider, HomeProvider homeProviderRef, int projectId) {
    if (!_formKey.currentState!.validate()) return;

    provider.updateStatus(onSuccess: (transNo) {
      onSaveDialog(
          context: context,
          title: "Success",
          transNo:"Trans no : $transNo",
          icon: Icons.check_circle_outlined,
          iconColor: bayaInfraGreen,
          message: "Observation Added Successfully",

          onClick: () {

            provider.initValues();
            GoRouter.of(context).pop();
            GoRouter.of(context).pop();
            GoRouter.of(context).pop();

          });
      ProviderScope.containerOf(context).read(allObservationRequestProvider).fetchObservationList(changeStart: true);
      ProviderScope.containerOf(context).read(myObservationProvider).fetchObservationList(changeStart: true);
      ProviderScope.containerOf(context).read(projectDetailsProvider).fetchObservationList(changeStart: true);
      ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      homeProviderRef.fetchPendingCount(projectIds: [projectId]);
    }, onFailure: (e) {
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


  static void _submitForm(BuildContext context, AddObservationProvider provider, HomeProvider homeProviderRef, int projectId) {
    if (!_formKey.currentState!.validate()) return;

    provider.addObservation(onSuccess: ({required String transNo}) {
      onSaveDialog(
          context: context,
          title: "Success",
          transNo:"Trans no : $transNo",
          icon: Icons.check_circle_outlined,
          iconColor: bayaInfraGreen,
          message: "Observation Added Successfully",

          onClick: () {
            provider.initValues();
            GoRouter.of(context).pop();
          });
      ProviderScope.containerOf(context).read(projectDashboardProvider).fetchDashboard();
      homeProviderRef.fetchPendingCount(projectIds: [projectId]);
    }, onFailure: (e) {
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

  static Future<void> _openImageViewer(BuildContext context, AddObservationProvider provider, int initialIndex) async {
    try {
      await provider.fetchAttachmentsDetail(
        attachmentList: provider.images,
      );

      if (provider.attachmentUrl.isNotEmpty) {
        final urls = provider.attachmentUrl.map((e) => e.url).toList();
        print("Urls --- $urls");

        if (context.mounted) {
          GoRouter.of(context).pushNamed(
            'imageViewer',
            extra: {
              'images': urls,
              'initialIndex': initialIndex,
            },
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No images found")),
        );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load images")),
        );
      }
    }
  }
}

removeAttachmentDialog({required BuildContext context,
  required Function() onTapYes,
}){
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Center(
              child: Text(
                "Confirm",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              )),
          content: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Do you want to remove this image?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,)


                ],
              )
          ),
          actions: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                    child: BaseElevatedButton(
                      borderRadius: 24,
                      backgroundColor: Theme.of(context).primaryColor,
                      text:"Yes",
                      onPressed: () {
                        onTapYes();
                        GoRouter.of(context).pop();
                      },
                    )),
                Expanded(
                    child: BaseElevatedButton(
                      borderRadius: 24,
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                      backgroundColor: bayaInfraDisabledColor,
                      text: "No",
                    )),

              ],
            ),
          ],
        );
      });
}