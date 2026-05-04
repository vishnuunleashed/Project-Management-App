

import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future showDialogBox(
        {required BuildContext context,
        Key? key,
        double? height,
        IconData? titleIcon,
        Color? iconColor,
          bool showLogOutButton = false,
        required String title,
        required String message,
        DialogButtonType buttonType = DialogButtonType.noButton,
        bool onWillPop = false,
        Function()? logOutAction,
        Function()? action}) =>
    showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
              onWillPop: () async {
                return onWillPop;
              },
              child: DialogBox(
                  key: key,
                  height: height,
                  titleIcon: titleIcon,
                  iconColor: iconColor,
                  title: title,
                  message: message,
                  showLogOutButton: showLogOutButton,
                  buttonType: buttonType,
                  logOutAction: logOutAction,
                  action: action),
            ));

class DialogBox extends StatelessWidget {
  const DialogBox(
      {Key? key,
      this.height,
      this.titleIcon,
      this.iconColor,
      required this.title,
      required this.message,
       this.showLogOutButton = false,
      this.buttonType = DialogButtonType.noButton,
        this.logOutAction,
      this.action})
      : super(key: key);

  final double? height;
  final IconData? titleIcon;
  final Color? iconColor;
  final String title;
  final String message;
  final DialogButtonType buttonType;
  final bool showLogOutButton;
  final Function()? action;
  final Function()? logOutAction;

  @override
  Widget build(BuildContext context) {
    String button1 = "";
    String button2 = "";
    double defaultHeight = MediaQuery.of(context).size.height;
    //Setting Button Text according to Button Type
    if (buttonType == DialogButtonType.okCancel) {
      button1 = "Ok";
      button2 = "Cancel";
    } else if (buttonType == DialogButtonType.yesNo) {
      button1 = "Yes";
      button2 = "No";
    } else if (buttonType == DialogButtonType.okOnly) {
      button1 = "Ok";
    } else if (buttonType == DialogButtonType.versionUpdate) {
      button1 = "Update Now";
      button2 = 'Log Out';
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: Center(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
              height: height ?? defaultHeight / 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    titleIcon != null
                        ? Icon(titleIcon,
                            size: 60,
                            color: iconColor ??
                                Theme.of(context)
                                    .iconTheme
                                    .color // Customize the icon color
                            )
                        : Container(),
                    Text(message,
                        textAlign: TextAlign.center,
                        maxLines: 6,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium)
                  ])),
        ),
        actions: <Widget>[
          Visibility(
              visible: (buttonType != DialogButtonType.noButton),
              child: buttonType != DialogButtonType.versionUpdate
                  ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Visibility(
                          visible: (buttonType != DialogButtonType.okOnly),
                          child: Expanded(
                            child: BaseElevatedButton(
                                text: button2,
                                onPressed: () {
                                  GoRouter.of(context).pop();
                                  // Close the dialog
                                }),
                          )),
                      SizedBox(width: 8,),
                      Expanded(
                        child: BaseElevatedButton(
                            text: button1,
                            onPressed: () {
                              action!();
                              // Navigator.of(context).pop(); // Close the dialog
                            }),
                      ),
                    ])

                  ///Text Button for version update
                  : showLogOutButton ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.transparent),
                    onPressed: () {
                      action!();
                    },
                    child: Text(
                      button1,
                      style:  TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color),
                    ),
                  ) ,   TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.transparent),

                    onPressed: () {
                      logOutAction!();
                    },
                    child: Text(
                      button2,
                      style:  TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                ],
              ):Center(
                      child: TextButton(
                      style: TextButton.styleFrom(backgroundColor: Colors.transparent),

                      onPressed: () {
                        action!();
                      },
                      child: Text(
                        button1,
                        style:  TextStyle(fontSize: 16,color: Theme.of(context).iconTheme.color),
                      ),
                    )))
        ]);
  }
}

enum DialogButtonType { okCancel, okOnly, yesNo, versionUpdate, noButton }
