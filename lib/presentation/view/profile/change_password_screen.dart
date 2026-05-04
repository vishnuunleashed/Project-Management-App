
/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 27/09/2025
PURPOSE		    : Change password page
MODULE/TOPIC	:
REMARKS		    : IN0034-25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_password_field.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/profile/profile_provider.dart';
import 'package:interior_design/presentation/view/profile/profile_picture.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/routes.dart';


class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProfileProvider>(
      initState: (context, provider, ref) {
        provider.initValues();
      },
      provider: profileProvider,
      builder: (context, provider, ref) {
        return SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            spacing: 6,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  const CurvedHeader(),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 16),
                      child: CircularBackButton(
                        onTap: () async {
                          GoRouter.of(context).pop(); // default

                        },
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Center(
                child: Text("Change Password",style:

                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                ),),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    spacing: 8,
                    children: [
                      BasePasswordField(
                        controller: provider.oldPassController,
                        validator: (val) {
                          return (val == null || val == "")
                              ? "Please enter current password"
                              : null;
                        },
                        paddingBtwTtlInp: 4,
                        displayTitle: "Current password",
                      ),
                      BasePasswordField(
                        controller: provider.newPassController,
                        paddingBtwTtlInp: 4,
                        displayTitle: "New password",
                        validator: (val) {
                          return (val == null || val == "")
                              ? "Please enter new password"
                              : (provider.newPassController.text.length < 5) ? "Password needs minimum 5 characters" : (provider.newPassController.text == provider.oldPassController.text) ? "New password must be different from current password" : null;
                        },
                      ),
                      BasePasswordField(
                        controller: provider.confirmNewPassController,
                        paddingBtwTtlInp: 4,
                        displayTitle: "Confirm password",
                        validator: (val) {
                          return (val == null || val == "")
                              ? "Please confirm password"
                              : (provider.confirmNewPassController.text != provider.newPassController.text) ? "Confirm password does not match. Please try again" : null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: BaseElevatedButton(
                          text: "Update",
                          onPressed: () {
                            if(provider.formKey.currentState!.validate()){
                                    provider.changePassword(onSuccess: (){
                                      provider.initValues();
                                      BaseDialog.show(
                                          context: context,
                                          icon: Icon(Icons.check_circle_outlined,color: bayaInfraGreen, size: 36,),
                                          title: "Success",
                                          message:"Password changed successfully. Please log in again with your new password",
                                          actions: [
                                            BaseElevatedButton(
                                              onPressed: (){
                                                print("button pressed");
                                                ref.read(homeProvider).onTabSelected(0);
                                                ref.read(homeProvider).resetSelectedIndex();
                                                ref.read(homeProvider).onItemTapped(0);
                                                ref.read(loginProvider).unsubscribeTopics();
                                                flutterLocalNotificationsPlugin.cancelAll();
                                                GoRouter.of(context).pushReplacement(AppRoutes.login);
                                              },
                                                text: "Ok")
                                          ]);

                                    });
                            }

                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
