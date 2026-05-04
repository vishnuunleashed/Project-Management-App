import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/project_location/project_location_provider.dart';



class OsmLocationPage extends StatelessWidget {

  const OsmLocationPage({Key? key,}) : super(key: key);




  @override
  Widget build(BuildContext context) {

    return BaseConsumer<ProjectLocationProvider>(
      provider: projectLocationProvider,

      builder:(context,provider,ref) {
        return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
              ),
              margin: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),

                clipBehavior: Clip.none,
                child: FlutterMap(
                  mapController: provider.mapController,

                  options: MapOptions(

                    initialCenter: provider.currentPosition,
                    initialZoom: 16,
                    onTap: (tapPosition, latlng) {
                      // provider.updateLocation(latlng);
                      // provider.focusNodeMap?.unfocus();

                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.infra.interior_design",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: provider.pickedPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 8,
            left: 4,
            right: 4,
            child: Card(
              elevation: 0.5,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wrong location / picked location text
                    Text(
                      "Selected Coordinates",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold),
                    ),


                    // Show lat/lng even if wrong
                    Text(
                      "Lat: ${provider.pickedPosition.latitude.toStringAsFixed(5)}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "Lng: ${provider.pickedPosition.longitude.toStringAsFixed(5)}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),



                  ],
                ),
              ),
            ),
          ),


          Positioned(
            top: 20, // adjust to fit your card & Pick button
            right: 16,
            child: InkWell(

              onTap: () async {

                provider.reCenter();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.1),
                    )
                  ],
                ),
                child:  Center(
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),


        ],
      );
      },
    );

  }
}