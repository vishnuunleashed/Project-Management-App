import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/services/settings.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? action;
  final double height;
  final Widget? bottom;
  final double? bottomHeight;
  final bool useLeading;
  final Color? backgroundColor;
  final Future<bool> Function(BuildContext context)? onBack;
  final bool? shadowNeeded;
  final double? elevation;

  const CustomAppBar(
      {Key? key,
      this.title,
      this.action,
      this.height = 58,
      this.bottom,
      this.bottomHeight,
      this.backgroundColor,
      this.useLeading = true,
      this.onBack,
      this.elevation,
      this.shadowNeeded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: (shadowNeeded != null)
            ? (shadowNeeded!)
                ? [
                    BoxShadow(
                      color: bayaInfraGreyColor.withOpacity(0.1), // soft shadow
                      offset: const Offset(0, 4), // only bottom
                      blurRadius: 20, // smooth blur
                      spreadRadius: 0, // no expansion
                    ),
                  ]
                : []
            : [],
      ),
      child: AppBar(
          centerTitle: false,
          backgroundColor:
              backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          toolbarHeight: height,
          forceMaterialTransparency: true,
          leadingWidth: 65, // Reduced from 60 to bring title closer
          elevation: elevation,
          automaticallyImplyLeading: false,
          titleSpacing: 0, // Reduced spacing between leading and title
          bottom: Bottom(
            bottom: bottom,
            bottomHeight: bottomHeight,
          ),
          leading: useLeading
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0), // Reduced from 8.0
                  child: CircularBackButton(
                    onTap: () async {
                      if (onBack != null) {
                        final canPop = await onBack!(context);
                        if (canPop) GoRouter.of(context).pop();
                      } else {
                        GoRouter.of(context).pop(); // default
                      }
                    },
                  ),
                )
              : null,
          title: title,
          titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
              ),
          actions: action),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}

class CircularBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? color;

  const CircularBackButton({super.key, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 70,
        height: 50,
        child: Center(
          child: Icon(
            Icons.arrow_back,
            color: color ?? Theme.of(context).textTheme.headlineLarge?.color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class Bottom extends StatelessWidget implements PreferredSizeWidget {
  final Widget? bottom;
  final double? bottomHeight;
  const Bottom({Key? key, this.bottom, this.bottomHeight}) : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(bottomHeight ?? 56);

  @override
  Widget build(BuildContext context) {
    return bottom ?? Container();
  }
}
