import 'package:base/presentation/base/base_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/utils/routes.dart';

class MainMenuOptions extends StatelessWidget {
  const MainMenuOptions({super.key});


  @override
  Widget build(BuildContext context) {
    return BaseView<HomeProvider>(
      provider: homeProvider,
      initState: (context,provider,ref){},
      builder: (context,provider,ref){
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Main Menu',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),


                ],
              ),
            ),

            _buildSection(
              context,
              title: "Options",
              subtitle: "Select an option to continue",
              icon: Icons.menu_open,
              sectionIndex: 0,
              actions: [

                _ActionItem("Document Control Center", Icons.folder,
                    iconBg: _sectionColors[0].cardAccents[1],
                    iconColor: _sectionColors[0].cardIconColors[1],
                    () {
                      GoRouter.of(context).pushNamed(AppRoutes.dccScreenDirect);
                    }),
              ],
            ),
          ],
        );
      },
    );
  }


}

class _SectionColors {
  final Color iconBg;
  final Color iconColor;
  final List<Color> cardAccents;
  final List<Color> cardIconColors;

  const _SectionColors({
    required this.iconBg,
    required this.iconColor,
    required this.cardAccents,
    required this.cardIconColors,
  });
}


class _ActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showMenu;
  final Color? iconBg;
  final Color? iconColor;

  _ActionItem(this.title, this.icon, this.onTap, {this.showMenu = true, this.iconBg, this.iconColor});
}


const _sectionColors = [
  // Observations — Steel Blue
  _SectionColors(
    iconBg: Color(0xFFEEF3F8),
    iconColor: Color(0xFF4A6580),
    cardAccents: [
      Color(0xFFEEF3F8),
      Color(0xFFF7ECE8),
      Color(0xFFEDF6EF),
      Color(0xFFF2EEF6),
      Color(0xFFEEF3F8),
    ],
    cardIconColors: [
      Color(0xFF4A6580),
      Color(0xFFB8745A),
      Color(0xFF4A8C55),
      Color(0xFF7B6C8D),
      Color(0xFF4A6580),
    ],
  ),

  // Support Requests — Terracotta
  _SectionColors(
    iconBg: Color(0xFFF7ECE8),
    iconColor: Color(0xFFB8745A),
    cardAccents: [
      Color(0xFFF7ECE8),
      Color(0xFFEDF6EF),
      Color(0xFFEEF3F8),
      Color(0xFFF2EEF6),
      Color(0xFFF7ECE8),
    ],
    cardIconColors: [
      Color(0xFFB8745A),
      Color(0xFF4A8C55),
      Color(0xFF4A6580),
      Color(0xFF7B6C8D),
      Color(0xFFB8745A),
    ],
  ),

  // Schedule — Moss Green
  _SectionColors(
    iconBg: Color(0xFFEDF6EF),
    iconColor: Color(0xFF4A8C55),
    cardAccents: [
      Color(0xFFEDF6EF),
      Color(0xFFEEF3F8),
      Color(0xFFF7ECE8),
      Color(0xFFF2EEF6),
    ],
    cardIconColors: [
      Color(0xFF4A8C55),
      Color(0xFF4A6580),
      Color(0xFFB8745A),
      Color(0xFF7B6C8D),
    ],
  ),

  // Material — Dusty Purple
  _SectionColors(
    iconBg: Color(0xFFF2EEF6),
    iconColor: Color(0xFF7B6C8D),
    cardAccents: [
      Color(0xFFF2EEF6),
      Color(0xFFEDF6EF),
    ],
    cardIconColors: [
      Color(0xFF7B6C8D),
      Color(0xFF4A8C55),
    ],
  ),
];


Widget _buildSection(
    BuildContext context, {
      required String title,
      required String subtitle,
      required IconData icon,
      required int sectionIndex,
      required List<_ActionItem> actions,
    }) {
  final textTheme = Theme.of(context).textTheme;
  final colors = _sectionColors[sectionIndex];

  return Card(
    color: Theme.of(context).cardColor,
    elevation: 0.5,
    child: Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: colors.iconBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.iconColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: colors.iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),


          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,     // 3 per row vertically
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,  // square tiles
              ),
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: actions.where((a) => a.showMenu).length,
              itemBuilder: (context, index) {
                final visibleActions = actions.where((a) => a.showMenu).toList();
                final action = visibleActions[index];

                final tileIconBg = action.iconBg ??
                    colors.cardAccents[index % colors.cardAccents.length];
                final tileIconColor = action.iconColor ??
                    colors.cardIconColors[index % colors.cardIconColors.length];

                return GestureDetector(
                  onTap: action.onTap,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.22,
                      margin: const EdgeInsets.only(right: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: tileIconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              action.icon,
                              color: tileIconColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Flexible(
                            child: Text(
                              action.title,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
              },
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    ),
  );
}

