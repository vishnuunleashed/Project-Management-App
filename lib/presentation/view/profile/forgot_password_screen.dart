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
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/profile/profile_provider.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/utils/routes.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> forgotFormKey = GlobalKey<FormState>();

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
                  child: Text("Forgot Password",style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                  ),),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    key: forgotFormKey,
                    child: Column(
                      spacing: 8,
                      children: [
                        BaseTextField(
                          isRequiredField: true,
                          isAutoValidateMode: true,
                          displayTitle: "Enter the registered username or email",
                          controller: provider.usernameEmailController,
                          customValidationMessage: "Please enter username or email",
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: BaseElevatedButton(
                            text: "Submit",
                            onPressed: () {
                              if (forgotFormKey.currentState!.validate()) {
                                provider.forgotPassword(onSuccess: () {
                                  provider.usernameEmailController.clear();
                                  BaseDialog.show(
                                      context: context,
                                      title: "Success",
                                      message: "Password reset link has been sent to your email. Please check your inbox (and spam/junk folder) to reset your password.",
                                      actions: [
                                        BaseElevatedButton(
                                          text: "Ok",
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            GoRouter.of(context).go(
                                                AppRoutes.login);
                                          },)
                                      ]);
                                });
                              }
                            }

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

// ---------------- Curved Header ----------------
class CurvedHeader extends StatelessWidget {
  const CurvedHeader({super.key});

  @override
  Widget build(BuildContext context) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 200,
                  decoration:  BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -15, // overlaps on curve
                child: CircleAvatar(
                  radius: 35,
                  child: Icon(Icons.lock_open,color: Theme.of(context).primaryColor,size: 30,),
                ) ),
            ],
         
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80); // start lower for more depth

    // Make the curve deeper by pulling the control point further down
    path.quadraticBezierTo(
      size.width / 2, size.height + 40, // control point lower
      size.width, size.height - 80,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
