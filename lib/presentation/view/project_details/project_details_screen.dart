/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    : Project Detail Page
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
1     22/08/2025  Brenta Roy    IN0011-25     Added didPopNext, fetchSupportRequestList
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/routes.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget  {
  const ProjectDetailsScreen({super.key});
  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> with RouteAware {

  @override
  void didPopNext()  {
    Future.microtask(() async {
        var calledFrom = ref.watch(calledFromOption);
        if (calledFrom != null && calledFrom == "MOB_CLOSE_SUPPORT_REQ") {
          await ref.read(projectDetailsProvider.notifier).fetchSupportRequestList();
          ref.read(calledFromOption.notifier).state = "";
          calledFrom = "";
        }
        if (calledFrom != null && calledFrom == "MOB_CLOSE_OBSERVATION") {
          await ref.read(projectDetailsProvider.notifier).fetchObservationList();
          ref.read(calledFromOption.notifier).state = "";
          calledFrom = "";
        }
        ref.read(homeProvider.notifier).fetchPendingCount(
            projectIds: [ref.read(projectDetailsProvider.notifier).projectId]);
        await ref.read(projectDetailsProvider.notifier).fetchProjectDetails(
            projectId: ref.read(projectDetailsProvider.notifier).projectId);

        final provider = ref.watch(projectDetailsProvider);
        provider.fetchSupportRequestList();

    });


    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return BaseView<ProjectDetailsProvider>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      provider: projectDetailsProvider,
      initState: (context, provider, ref) async {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;

        final obsRight = ref.read(homeProvider.notifier).closeObservationRight;
        final supRight = ref.read(homeProvider.notifier).closeSupportRight;

        provider.initState(extra:extra);

        provider.getUserDetails();
        provider.fetchOwners();
        onMessageGeneralListener(onListenerInvoke: (){
          if(provider.selectedTab == 'OBV' ){
            provider.fetchObservationList(changeStart: true);
          }
          else if(provider.selectedTab == 'SPR'){
            provider.fetchSupportRequestList(changeStart: true);
          }
        });
      },
      dispose: (context){
        if(generalScreenListener != null){
          generalScreenListener?.cancel();
        }
        ProjectDetailsProvider().disposeVariables();
      },
      appBar:  CustomAppBar(
        onBack: (value) async{
          ref.watch(homeProvider).onItemTapped(0);
          ref.watch(homeProvider).onTabSelected(0);
          return true;
        },
        title: Text("Project Details"),
      ),
      builder: (context, provider, ref) {
        return WillPopScope(
          onWillPop: () async{
            ref.watch(homeProvider).onItemTapped(0);
            ref.watch(homeProvider).onTabSelected(0);
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 4),
            child: LayoutBuilder(
              builder: (context,constraint) {
                return ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // ProjectHeaderCard(
                        //     projectName: provider.projectDetailList.isEmpty
                        //         ? ""
                        //         : provider.projectDetailList.first.projectName??"",
                        //     endDate: provider.projectDetailList.isEmpty
                        //         ? DateTime.now()
                        //         :provider.projectDetailList.first.endDate??DateTime.now(),
                        //     locationName: provider.projectDetailList.isEmpty
                        //         ? ""
                        //         :provider.projectDetailList.first.location??"",
                        //
                        // ),
                        // const SelectionTab(),

                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraint.maxHeight,
                          ),
                          child: PageView(
                            controller: provider.pageController,
                            onPageChanged: (index) {

                              if(provider.currentPage != index){
                              provider.goToPage(index: index, isFromButtonClick: false);
                              }
                            },
                            children: provider.tabs.map((tab) => tab['widget'] as Widget).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }
}

