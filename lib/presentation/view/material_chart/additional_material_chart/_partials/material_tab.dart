// import 'package:base/presentation/base/base_stateless_consumer.dart';
// import 'package:base/presentation/theme_config.dart';
// import 'package:flutter/material.dart';
// import 'package:interior_design/presentation/provider/call_tracker/service_request_dashboard_provider.dart';
// import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
// import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_chart_main_provider.dart';
// import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
//
// class MaterialSelectionTab extends StatelessWidget {
//   const MaterialSelectionTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseStatelessConsumer<AdditionalMaterialMainProvider>(
//       provider: additionalMaterialMainProvider,
//       builder: (context, provider, ref) {
//
//
//         return Row(
//           children: [
//
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () {
//                     provider.goToPage(
//                       index: 0,
//                     );
//                   },
//                   child: AnimatedPhysicalModel(
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeInOut,
//                     elevation: provider.isSelected[0] ? 1 : 0.5,
//                     shape: BoxShape.rectangle,
//
//                     color:  provider.isSelected[0]
//                         ? Theme.of(context).primaryColor
//                         : Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(12),
//                     shadowColor: Theme.of(context).colorScheme.primary,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 12.0),
//                       child: Center(
//                         child: Text(
//                           "All Materials",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color:  provider.isSelected[0]
//                                 ? Theme.of(context).colorScheme.onPrimary
//                                 : Theme.of(context)
//                                 .textTheme
//                                 .titleLarge
//                                 ?.color
//                                 ?.withOpacity(0.5),
//                             fontWeight:  provider.isSelected[0] ? FontWeight.w700 : FontWeight.w300,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () {
//                     provider.goToPage(
//                     index: 1,
//                   );
//                   },
//                   child: AnimatedPhysicalModel(
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeInOut,
//                     elevation:  provider.isSelected[1] ? 1 : 0.5,
//                     shape: BoxShape.rectangle,
//
//                     color: provider.isSelected[1]
//                         ? Theme.of(context).primaryColor
//                         : Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(12),
//                     shadowColor: Theme.of(context).colorScheme.primary,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 12.0),
//                       child: Center(
//                         child: Text(
//                           "Update Received Qty",
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: provider.isSelected[1]
//                                 ? Theme.of(context).colorScheme.onPrimary
//                                 : Theme.of(context)
//                                 .textTheme
//                                 .titleLarge
//                                 ?.color
//                                 ?.withOpacity(0.5),
//                             fontWeight: provider.isSelected[1] ? FontWeight.w700 : FontWeight.w300,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
