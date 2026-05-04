import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showLongTextDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Close",
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar:CustomAppBar(
          title: Text("Points"),

        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Scrollbar(
              thumbVisibility: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: double.infinity),
                        child: SelectableText(
                          content,
                          style: Theme.of(ctx).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  BaseElevatedButton(
                      text: "Close",
                  onPressed: (){
                        GoRouter.of(context).pop();
                  },)
                  
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final tween =
      Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
