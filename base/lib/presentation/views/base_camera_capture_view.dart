
import 'dart:io';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'base_elevated_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _initializing = true;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No camera available';
          _initializing = false;
        });
        return;
      }
      final camera = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false,imageFormatGroup: ImageFormatGroup.jpeg);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
        _initializing = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      if (!mounted) return;
      File imageFile = File(file.path);
      Navigator.of(context).pop<List<File>>([imageFile]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture failed: $e')));
    }
  }

  Future<void> _switchCamera() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.length < 2) return; // Need at least 2 cameras to switch

      // Determine current camera direction
      final currentDescription = _controller!.description;
      CameraDescription newCamera;

      // Switch to the opposite camera
      if (currentDescription.lensDirection == CameraLensDirection.back) {
        // Switch to front camera
        newCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        // Switch to back camera
        newCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      // Dispose current controller
      await _controller!.dispose();

      // Initialize new controller with the switched camera
      _controller = CameraController(
          newCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {}); // Refresh the UI
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera switch failed: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.white),
          ))
          : SafeArea(
        child: Stack(
          children: [
            Center(
              child: CameraPreview(_controller!),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween  ,
                children: [
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
                      child:FloatingActionButton(
                        heroTag: 'switch_camera_fab',
                        shape: const CircleBorder(),
                        elevation: 0,
                        onPressed: _switchCamera,
                        backgroundColor: Colors.black.withAlpha(80),
                        child: const Icon(Icons.flip_camera_ios_outlined,color: Colors.white60),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
                        child: FloatingActionButton(highlightElevation: 10,
                          heroTag: 'pick_fab',
                          shape: const CircleBorder(),
                          elevation: 0,
                          onPressed: () async {

                            final files = await pickFromGallery(context);
                            if (files.isNotEmpty) {
                              // provider.uploadImageFile(files);
                              Navigator.of(context).pop<List<File>>(files);
                            }
                          },
                          backgroundColor: Colors.black.withAlpha(80),
                          child: const Icon(Icons.image, color: Colors.white60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: FloatingActionButton(
                          heroTag: 'capture_fab',
                          shape: const CircleBorder(),
                          elevation: 0,
                          onPressed: _takePicture,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
                          child: FloatingActionButton(

                            heroTag: 'close_fab',
                            shape: const CircleBorder(),
                            elevation: 0,
                            onPressed: () => Navigator.of(context).pop(),
                            backgroundColor: Colors.black.withAlpha(80),
                            child: const Icon(Icons.close, color: Colors.white60),
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<File>> pickFromGallery(BuildContext context) async {
    // Request permissions
    PermissionStatus imageStatus;
    if (Platform.isIOS) {
      imageStatus = await Permission.photos.request();
    } else {
      // Android: Try Photos (Android 13+) else fallback to Storage
      imageStatus = await Permission.photos.request();
      if (!imageStatus.isGranted) {
        imageStatus = await Permission.storage.request();
      }
    }
    if(!Platform.isIOS){
    if (!imageStatus.isGranted) {
      if (imageStatus.isPermanentlyDenied) {
        permissionBox(context, 'Gallery permission permanently denied. Please enable it from Settings.');
      } else {
        permissionBox(context, "Gallery permission denied. Please enable it from Settings.");
      }
      return [];
    }
    }
    try {
      final images = await _picker.pickMultiImage();
      if (images.isEmpty) {
        return [];
      }
      return images.map((x) => File(x.path)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick images: $e")),
      );
      return [];
    }
  }


  void permissionBox(BuildContext context, String message) {
    BaseDialog.show(
        context: context,
        title: "Gallery permission",
        message: message,
        actions:  [
      Row(
        spacing: 6,
        children: [
          Expanded(
            child: BaseElevatedButton(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor ,
              onPressed: () {
                openAppSettings();
                GoRouter.of(context).pop();
              },// exit
              text:"Open Settings",
            ),
          ),
          Expanded(
            child: BaseElevatedButton(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              borderRadius: 24,
              backgroundColor: bayaInfraDisabledColor,
              onPressed: () => GoRouter.of(context).pop(), // stay
              text:"Cancel",
            ),
          ),
        ],
      )
      ],

    );
  }
}
