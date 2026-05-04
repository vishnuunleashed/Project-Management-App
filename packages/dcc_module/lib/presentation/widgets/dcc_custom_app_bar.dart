import 'package:flutter/material.dart';

class DccCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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

  const DccCustomAppBar({
    Key? key,
    this.title,
    this.action,
    this.height = 58,
    this.bottom,
    this.bottomHeight,
    this.backgroundColor,
    this.useLeading = true,
    this.onBack,
    this.elevation,
    this.shadowNeeded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        boxShadow: (shadowNeeded != null && shadowNeeded!)
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: AppBar(
        centerTitle: false,
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: height,
        forceMaterialTransparency: true,
        leadingWidth: useLeading?65:12,
        elevation: elevation,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        bottom: DccBottom(
          bottom: bottom,
          bottomHeight: bottomHeight,
        ),
        leading: useLeading
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: DccCircularBackButton(
                  onTap: () async {
                    if (onBack != null) {
                      final canPop = await onBack!(context);
                      if (canPop) {
                        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                      }
                    } else {
                      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                    }
                  },
                ),
              )
            : SizedBox(),
        title: title,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
        actions: action,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class DccCircularBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? color;

  const DccCircularBackButton({super.key, required this.onTap, this.color});

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

class DccBottom extends StatelessWidget implements PreferredSizeWidget {
  final Widget? bottom;
  final double? bottomHeight;
  const DccBottom({Key? key, this.bottom, this.bottomHeight}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(bottomHeight ?? 56);

  @override
  Widget build(BuildContext context) {
    return bottom ?? Container();
  }
}
