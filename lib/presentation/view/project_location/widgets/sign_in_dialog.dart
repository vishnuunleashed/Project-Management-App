import 'dart:io';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';

void logInDialog(
    {required BuildContext context,
    required File image,
      LocationData? position,
    required void Function()? onPressed,
    String? address,}){
  double defaultHeight = MediaQuery.of(context).size.height;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(
          child: Text('Confirm Check-In location',style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(image.path.isNotEmpty)
                  Center(
                  child: Image.file(
                    File(image.path),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Address: ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                    ),
                    TextSpan(
                      text: address,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                softWrap: true,
                maxLines: null,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Latitude: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextSpan(
                      text: position?.latitude.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                softWrap: true,
                maxLines: null,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Longitude: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextSpan(
                      text: position?.longitude.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                softWrap: true,
                maxLines: null,
              ),

            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:  Theme.of(context).primaryColor,
            ),
            onPressed: () => Navigator.of(context).pop(), // cancel
            child: Text('Cancel',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: bayaInfraWhiteColor),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:  Theme.of(context).primaryColor,
            ),
            onPressed: onPressed,
            child: Text('Check-In',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: bayaInfraWhiteColor)),
          ),
        ],
      );
    },
  );
}


