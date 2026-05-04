/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 13/08/2025
PURPOSE		    : IN0011-25
MODULE/TOPIC	:
REMARKS		    : Add Support request Screen
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_view_or_fill_dto.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/add_support_request/add_support_request_provider.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/view/add_support_request/partials/add_support_request_form.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/dependency_task_card.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/header_card_schedule.dart';

class AddSupportRequestScreen extends ConsumerStatefulWidget {
  AddSupportRequestScreen({super.key});

  @override
  ConsumerState<AddSupportRequestScreen> createState() => _AddSupportRequestScreenState();
}

class _AddSupportRequestScreenState extends ConsumerState<AddSupportRequestScreen> {
  final GlobalKey<FormState> formKey = GlobalKey();

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
            )
          ],
        ),
      ],
    );

    return shouldExit ?? false; // false = don't pop
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context);
    AddSupportRequestProvider _addSupportRequestProvider = container.read(addSupportRequestProvider);
    return WillPopScope(
      onWillPop: () async {
        final hasRemarks = _addSupportRequestProvider.pointsController.text.isNotEmpty;

        if (hasRemarks) {
          return await _onWillPop(context);
        }
        return true;
      },
      child: BaseView<AddSupportRequestProvider>(
          provider: addSupportRequestProvider,
          appBar: CustomAppBar(title: Consumer(builder: (context, ref, __) {
            final p = ref.watch(addSupportRequestProvider);
            final title = p.optionName.isNotEmpty ? p.optionName : "Add Support Request";
            return Text(title);

          }
          ),
            onBack: (context) async {
              final hasRemarks = _addSupportRequestProvider.pointsController.text.isNotEmpty;
              if (hasRemarks) {
                return await _onWillPop(context); // show confirm
              }
              return true; // exit directly
            },          ),
          initState: (context, provider, ref) {
            //Init
            provider.initValues();
            final state = GoRouterState.of(context);
            final extra = state.extra as Map<String, dynamic>?;
            provider.setParameter(extra,extra!["projectId"]??0);
            //To set ProjectId

                      //To Set Option Details
            final UserRightsModel optionObj = ref.watch(homeProvider).rightsLists.where((element) => element.optionCode == "MOB_ADD_SUPPORT_REQUEST").first;

            provider.setOptionDetails(optionObj: optionObj);


          },
          virtualFloatingActionButton: BaseStatelessConsumer(
            provider: addSupportRequestProvider,
            builder: (context, provider, ref) {
              return Visibility(
                visible: provider.isFromSchedules,
                child: ExpandableFab(
                  bottomPadding: 30,
                  distance: 70,
                ),
              );
            },
          ),


          dispose: (context){
            ProjectDetailsProvider().disposeVariables();
          },
          builder: (context, provider, ref) {
            final textFieldFocusNode = FocusNode();
            final deptKey = GlobalKey<DropdownSearchState<DepartmentDropDownObj>>();
            List<ProjectTaskDtlModel> projectTaskDtlModel = ref.watch(projectScheduleProvider).projectTaskFillData;
            return Column(children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Form(
                          key: formKey,
                          child: Column( children: [
                            Visibility(
                                visible: !provider.isFromSchedules,
                                child: provider.projectDetailList.isEmpty
                                    ? SizedBox(height: 0,)
                                    : ProjectHeaderCard(
                                    projectName: provider.projectDetailList.first.projectName??"",
                                    endDate: provider.projectDetailList.first.endDate??DateTime.now(),
                                    locationName: provider.projectDetailList.first.location??""
                                ),),
                            Visibility(
                              visible: provider.isFromSchedules,
                              child: Column(
                                children: [
                                  projectTaskDtlModel.isEmpty
                                          ? SizedBox(height: 0)
                                          : DependencyTaskCard(
                                        taskTypeHeader: "Request against task schedule",
                                        taskName: projectTaskDtlModel.first.taskName??"",
                                        taskId: projectTaskDtlModel.first.taskId??0,
                                        profilePicture: projectTaskDtlModel.first.taskuserprofileurl??"",
                                        userName: projectTaskDtlModel.first.taskUser??"",
                                        remainingDays: projectTaskDtlModel.first.duration??"",
                                        taskStatus: projectTaskDtlModel.first.status??"",

                                  ),
                                ],
                              ),
                            ),
                            AddSupportRequestForm(deptKey:deptKey ,textFieldFocusNode: textFieldFocusNode,)

                          ],
                          ),
                      ),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: BaseElevatedButton(
                            text: "Clear",
                            textColor: Theme.of(context).textTheme.titleLarge?.color ?? Colors.grey,
                            backgroundColor:Theme.of(context).scaffoldBackgroundColor,
                            borderColor: Theme.of(context).textTheme.titleLarge?.color ??Colors.grey,
                            elevation: 0,
                            onPressed: () {
                              provider.initValues();
                              formKey.currentState!.reset();
                              // deptKey.currentState!.clear();
                            })),
                    Expanded(
                      child: BaseElevatedButton(
                          text: 'Submit',

                          onPressed: () {
                            var formState = formKey.currentState;
                            if (formState!.validate()) {
                              provider.addSupportRequest();
                              textFieldFocusNode.unfocus();
                            }
                          }),
                    )
                  ],
                ),
              )

            ]);
          }),
    );
  }
}