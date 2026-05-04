import 'package:base/presentation/base/base_stateless_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_schedule/graph_based_support_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/expandable_fab.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/date_range_tile.dart';

import 'graph_based_support_main_widget.dart';


class GraphBasedSupportRequestScreen extends StatelessWidget {
  const GraphBasedSupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<GraphBasedSupportProvider>(
        initState: (context, provider, ref) {
          final state = GoRouterState.of(context);
          final extra = state.extra as Map<String, dynamic>?;
          provider.initState();
          provider.setNavigationParameters(extra:extra??{});
          provider.getUserDetails();
          provider.initSupScrollListener();
          provider.fetchOwners();
        },
        provider: graphBasedSupportProvider,
        appBar: CustomAppBar(
          title: BaseStatelessConsumer<GraphBasedSupportProvider>(
            provider: graphBasedSupportProvider,
            builder: (context, provider, ref) {
              return Text("Support Requests Overcome Delay",
                style: Theme.of(context).textTheme.titleLarge,);
            },
          ),
        ),


        virtualFloatingActionButton: BaseStatelessConsumer(
          provider: graphBasedSupportProvider,
          builder: (context, provider, ref) {
            final _homeProvider = ref.watch(homeProvider);
            return ExpandableFab(
              bottomPadding: 0,
              distance: 70,
            );
          },
        ),
        builder: (context, provider, ref) {

          return _mainWidget(context, provider, ref) ;


        });
  }

  Widget _mainWidget(BuildContext context,GraphBasedSupportProvider provider,WidgetRef ref){
    return Column(
      children: [
        Visibility(
          visible: !provider.isFromDashboard,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/svgs/project_icon.svg',
                    ),
                  ),
                ),
                SizedBox(width: 4,),
                Text(
                  provider.projectDetailList.isEmpty?"":provider.projectDetailList.first.projectName?? "",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: provider.isFromDashboard,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                onTap: () {
                  ProfileImageDialog.show(context: context,
                  imageUrl: provider.userprofileurl ?? "User",
                  userName:  provider.raisedUser ?? "",);

                  },
                    child: CachedNetworkImageWidget(
                      imageUrl:  provider.userprofileurl ?? "",
                      size: 45,
                      userName: provider.raisedUser,

                    ),
                  ),
                SizedBox(width: 4,),
                Text(
                  provider.raisedUser,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),),
        Expanded(
          child: GraphBasedSupportRequestMainWidget(),
        )
      ],
    );
  }




}
