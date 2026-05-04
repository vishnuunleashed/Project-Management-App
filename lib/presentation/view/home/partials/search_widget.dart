// /*------------------------------------------------------------------------------
// AUTHOR		    :Aswani Mohan
// CREATED DATE	: 07/08/2025
// PURPOSE		    :
// MODULE/TOPIC	:
// REMARKS		    :
// --------------------------------------------------------------------------------
// REVISION HISTORY
// --------------------------------------------------------------------------------
// REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
// --------------------------------------------------------------------------------*/
// import 'package:base/presentation/base/base_stateless_consumer.dart';
// import 'package:base/presentation/theme_config.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:interior_design/presentation/provider/Home/home_provider.dart';
// import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
//
// class SearchWidget extends StatelessWidget {
//   const SearchWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseStatelessConsumer<HomeProvider>(
//       provider: homeProvider,
//       builder: (context, provider, ref) {
//         return Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.secondary,
//               border: Border.all(width: 0.5, color: bayaInfraGreyColor),
//               borderRadius: BorderRadius.circular(22),
//             ),
//             child: Stack(
//               alignment: Alignment.centerLeft,
//               children: [
//                 // Row with leading icon + animated text field + notifications
//                 Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0,left: 8,bottom: 8),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).highlightColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: FittedBox(
//                           fit: BoxFit.contain,
//                           child: Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: SvgPicture.asset(
//                               width: 35,
//                               height: 35,
//                               'assets/svgs/icon.svg',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Animated text field
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       curve: Curves.linear,
//                       width: provider.isSearching ? 180 : 0,
//                       child: AnimatedOpacity(
//                         opacity: provider.isSearching ? 1.0 : 0.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: TextField(
//                           focusNode: provider.searchFocusNode,
//                           controller: provider.searchController,
//                           onChanged: (value){
//                           provider.changeSearchText(value);
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Search...',
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: const EdgeInsets.symmetric(vertical: 20),
//                             prefixIcon: Icon(
//                               Icons.search_outlined,
//                               color: Theme.of(context).colorScheme.primary,
//                               size: 24,
//                             ),
//                           ),
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ),
//                     ),
//
//                     const Spacer(),
//
//                     // Notifications Button stays fixed
//                     IconButton(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.notifications_none_outlined,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // Animated search icon that moves from right to left
//                 AnimatedPositioned(
//                   duration: const Duration(milliseconds: 400),
//                   curve: Curves.easeInOut,
//                   right: provider.isSearching ? MediaQuery.of(context).size.width - 120 : 40,
//                   child: AnimatedOpacity(
//                     opacity: provider.isSearching ? 0.0 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     child: IconButton(
//                       onPressed: () {
//                         provider.changeIsSearching();
//                       },
//                       icon: Icon(
//                         Icons.search_outlined,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // Close Button - appears when search is active
//                 if (provider.isSearching)
//                   Positioned(
//                     right: 40,
//                     child: IconButton(
//                       onPressed: () {
//                         provider.changeIsSearching();
//                         provider.searchController.clear();
//                       },
//                       icon: Icon(
//                         Icons.close,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }