
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:base/presentation/views/base_camera_capture_view.dart';

class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();


  Future<List<File>?> pickImage(BuildContext context) async {
    if(!Platform.isIOS) {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          permissionBox(context, 'Camera permission permanently denied.');
        } else {
          permissionBox(context, 'Camera permission denied.');
        }
        return null;
      }
    }
    try {
      final List<File>? files = await Navigator.of(context).push<List<File>>(
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
      if (files == null) return null;
      return files;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
      return null;
    }
  }


  void permissionBox(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        title: const Text('Camera Permission'),
        content: Text('$message Please grant permission in app settings.'),

        elevation: 10,
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => GoRouter.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              GoRouter.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
