import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_location/project_location_provider.dart';
import 'package:interior_design/presentation/state/app_state.dart';
import 'map_picker_page.dart';

class ProjectLocationPage extends StatefulWidget {
  const ProjectLocationPage({super.key});

  @override
  State<ProjectLocationPage> createState() => _ProjectLocationPageState();
}

class _ProjectLocationPageState extends State<ProjectLocationPage> {


  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectLocationProvider>(
      initState: (context,provider,ref){
        provider.initValues();
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.setParameter(extra);
        provider.getGeoCoordinatedByProject(projectId:  extra != null && extra["transid"] != null
            ? extra["transid"]
            : extra!["projectId"]??0);

        if(extra["notificationid"] != null){
          provider.setNotificationId(extra["notificationid"]);
        }else if(extra["notificationId"] != null){
          provider.setNotificationId(extra["notificationId"]);
        }

      },
      provider: projectLocationProvider,
      appBar: CustomAppBar(
        shadowNeeded: true,
        title: const Text("Project Location"),
      ),
      builder:(context,provider,ref) {
        return provider.loadingStatus.loader == Loader.success
                  && ((provider.locationList.isNotEmpty
                      && provider.locationList.first.allowaccessyn == "N" ))
            ? Center(
                child: SizedBox(
                height: MediaQuery.of(context).size.height/2,
                width: MediaQuery.of(context).size.width,
                child: Center(child: locationWidget(context,
                  (provider.locationList.isNotEmpty
                        && provider.locationList.first.allowaccessyn == "Y")),
               ),
             ),
            )
            :Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: provider.useCurrentLocation,
                              icon: const Icon(Icons.my_location,color: bayaInfraWhiteColor,),
                              label: Text("Use Current Location",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color:bayaInfraWhiteColor)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: bayaInfraWhiteColor,
                                padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                          ],
                        ),


                        const SizedBox(height: 8),
                        Text(
                            "Project Radius & Tolerance",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),


                        const SizedBox(height: 8),

                       Form(
                            key: _formKey,
                            child: Row(
                              children: [

                                // Tolerance field
                                Expanded(
                                  child: BaseTextField(
                                    controller: provider.radiusController,
                                    textInputType: TextInputType.number,
                                    displayTitle: "Radius (meters)",
                                    hintText: "e.g., 200",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                    isRequiredField: false,
                                    maxLines: 1,
                                    cursorHeight: 18,
                                    customValidator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return "Please enter Radius (meters)";
                                      }

                                      final radius = double.tryParse(value);

                                      if (radius == null || radius <= 1) {
                                        return "Radius must be >1 meter";
                                      }

                                      return null;
                                    },
                                    onChanged: (v) => provider.updateTolerance(v),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Tolerance field
                                Expanded(
                                  child: BaseTextField(
                                    controller: provider.toleranceController,
                                    textInputType: TextInputType.number,
                                    maxLines: 1,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                    cursorHeight: 18,
                                    displayTitle: "Tolerance (meters)",
                                    hintText: "e.g., 50",
                                    onChanged: (v) => provider.updateTolerance(v),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8),
                        Text(
                          "Saved Locations",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 8),
                        Visibility(
                          visible: provider.savedLocations.isNotEmpty,
                          child: Builder(
                              builder: (context) {
                                final loc = provider.savedLocations.last;
                                return Card(
                                  elevation: 0.5,
                                  color: Theme.of(context).cardColor,
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 12),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Column(
                                            children: [
                                              const Icon(Icons.location_on, color: bayaInfraRedColor),
                                              SizedBox(height: 4,),

                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                loc.title,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                              ),
                                              Text(
                                                loc.subtitle,
                                                style: Theme.of(context).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                        ),

                      ],
                    ),

                    provider.loadingStatus.loader == Loader.success
                        && (provider.savedLocations.isEmpty)
                        ? Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height/2,
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: locationWidget(context,true),
                            ),
                          ),
                        )
                        :SizedBox(
                            height: MediaQuery.of(context).size.height/2,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0,vertical: 16),
                          child: OsmLocationPage(),
                            ),
                    ),


                  ],
                ),
              ),
            ),

           Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: BaseElevatedButton(
                        height: 40,

                        onPressed: () {
                          provider.initValues();
                        },
                        text: "Clear",
                        textColor: Theme.of(context).textTheme.titleMedium?.color ?? Colors.grey,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        borderColor: Theme.of(context).textTheme.titleMedium?.color ?? Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BaseElevatedButton(
                        height: 40,
                        onPressed: () {
                            if(provider.savedLocations.isEmpty){
                              BaseSnackBar().show(message: "Please select the current location");
                              return;
                            }
                            if(_formKey.currentState!.validate()){

                                provider.captureGeoLocation();
                            }
                          },
                        text: 'Submit',
                      ),
                    ),
                  ],
                ),
           ),

          ],
        ),
      );
      },
    );
  }
}

Widget locationWidget(BuildContext context,bool allowAccess) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Visibility(
        visible: !allowAccess,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
          child: Text("Project location cannot be viewed since you have no rights.",
              textAlign: TextAlign.center,
              style:  Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: bayaInfraRedColor
              )),
        ),
      ),
      Visibility(
        visible: allowAccess,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please select the current location',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      SizedBox(
        height: 80,
        width:  80,
        child: Image.asset(
          'assets/png/map.png',
          fit: BoxFit.fill,
          width: double.infinity,
        ),
      ),
    ],
  );
}