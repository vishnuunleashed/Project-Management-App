import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;


/// Service class for single image upload with crop
class SingleImageService {
  SingleImageService._();
  static final SingleImageService instance = SingleImageService._();



  /// Pick a single image with crop feature
  Future<File?> pickImageWithCrop(
      {required BuildContext context, bool showGalleryUpload = true}) async {
    if (!Platform.isIOS) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showPermissionDialog(context, status.isPermanentlyDenied);
        return null;
      }
    }

    try {
      final File? file = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) =>  SingleImageCaptureScreen(showGalleryUpload: showGalleryUpload),
        ),
      );
      return file;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
      return null;
    }
  }

  void _showPermissionDialog(BuildContext context, bool isPermanent) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission'),
        content: Text(
          isPermanent
              ? 'Camera permission permanently denied. Please grant permission in app settings.'
              : 'Camera permission denied. Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          if (isPermanent)
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

/// Main screen for capturing single image
class SingleImageCaptureScreen extends StatefulWidget {
  final bool showGalleryUpload;
  const SingleImageCaptureScreen({super.key,this.showGalleryUpload =true});

  @override
  State<SingleImageCaptureScreen> createState() =>
      _SingleImageCaptureScreenState();
}

class _SingleImageCaptureScreenState extends State<SingleImageCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras available')),
          );
        }
        return;
      }

      // Find front camera, fallback to first camera if not found
      CameraDescription selectedCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0],
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Take Photo'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // Camera preview
            if (_isCameraInitialized && _controller != null)
              Center(child: CameraPreview(_controller!))
            else
              const Center(child: CircularProgressIndicator()),

            // Processing overlay
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Bottom controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    widget.showGalleryUpload?IconButton(
                        onPressed: _isProcessing ? null : _pickFromGallery,
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        iconSize: 36,
                      )
                        :const SizedBox(width: 36),


                    // Capture button
                    GestureDetector(
                      onTap: _isProcessing || !_isCameraInitialized
                          ? null
                          : _captureImage,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // Switch camera button
                    if (_cameras != null && _cameras!.length > 1)
                      IconButton(
                        onPressed: _isProcessing ? null : _switchCamera,
                        icon: const Icon(Icons.flip_camera_ios,
                            color: Colors.white),
                        iconSize: 36,
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentIndex = _cameras!.indexOf(_controller!.description);
    final newIndex = (currentIndex + 1) % _cameras!.length;

    final oldController = _controller;

    setState(() => _isCameraInitialized = false);

    _controller = CameraController(
      _cameras![newIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await oldController?.dispose();
    await _controller!.initialize();

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      // Check if image was taken from front camera
      final isFrontCamera = _controller!.description.lensDirection == CameraLensDirection.front;
      await _processCapturedImage(File(image.path), isFrontCamera);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Gallery images are not flipped
        await _processCapturedImage(File(image.path), false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking from gallery: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<File> flipImageHorizontally(File imageFile) async {
    // Read the image file
    final bytes = await imageFile.readAsBytes();

    // Decode the image
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Unable to decode image');
    }

    // Flip the image horizontally
    img.Image flippedImage = img.flipHorizontal(image);

    // Encode back to jpg/png
    final flippedBytes = img.encodeJpg(flippedImage);
    // or use img.encodePng(flippedImage) for PNG

    // Save to a new file or overwrite the original
    final flippedFile = await imageFile.writeAsBytes(flippedBytes);

    return flippedFile;
  }

  Future<void> _processCapturedImage(File imageFile, bool shouldFlip) async {
    // Step 1: Flip the image only if it's from front camera
    File processedImage = imageFile;
    if (shouldFlip) {
      processedImage = await flipImageHorizontally(imageFile);
    }

    // Step 2: Crop the image
    final croppedFile = await _cropImage(processedImage.path);

    if (croppedFile == null) {
      // User cancelled cropping
      return;
    }

    // Step 3: Show preview and get confirmation
    if (!mounted) return;

    final shouldUpload = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(imageFile: File(croppedFile.path)),
      ),
    );

    // Step 4: Return the image if user confirmed
    if (shouldUpload == true && mounted) {
      Navigator.of(context).pop(File(croppedFile.path));
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 1.0,
        ),
      ],
    );
  }
}

/// Preview screen to view the cropped image before uploading
class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Preview'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Column(
          children: [
            // Image preview
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                children: [
                  // Retake button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Upload button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage:
/*
  // In your widget:
  Future<void> _selectImage() async {
    final File? image = await SingleImageService.instance.pickImageWithCrop(context);

    if (image != null) {
      // Use the image
      print('Image selected: ${image.path}');
      // Upload to server, display, etc.
    }
  }
*/