import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaServiceWithCrop {
  MediaServiceWithCrop._();
  static final MediaServiceWithCrop instance = MediaServiceWithCrop._();

  /// Pick images - goes directly to camera screen with gallery option
  Future<List<File>?> pickImage(
      BuildContext context, {
        bool enableMultiSelect = false,
        bool enableCrop = false,
        bool enableDoodling = false,
      }) async {
    if (!Platform.isIOS) {
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
        MaterialPageRoute(
          builder: (_) => CameraScreenWithCrop(
            enableMultiSelect: enableMultiSelect,
            enableCrop: enableCrop,
          ),
        ),
      );
      return files;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open camera: $e')),
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

class CameraScreenWithCrop extends StatefulWidget {
  final bool enableMultiSelect;
  final bool enableCrop;

  const CameraScreenWithCrop({
    super.key,
    this.enableMultiSelect = false,
    this.enableCrop = false,
  });

  @override
  State<CameraScreenWithCrop> createState() => _CameraScreenWithCropState();
}

class _CameraScreenWithCropState extends State<CameraScreenWithCrop> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  List<File> selectedImages = [];
  bool isProcessing = false;
  bool _isCameraInitialized = false;
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

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
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
          title: const Text('Select Images'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            if (selectedImages.isNotEmpty)
              Container(
                height: 120,
                padding: const EdgeInsets.all(8),
                color: Colors.black,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Open image editor for crop and doodle
                            final editedFile = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageEditorScreen(
                                  imageFile: selectedImages[index],
                                  enableCrop: widget.enableCrop,
                                ),
                              ),
                            );

                            if (editedFile != null && editedFile is File) {
                              setState(() {
                                selectedImages[index] = editedFile;
                              });
                            }
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  if (_isCameraInitialized && _controller != null)
                    CameraPreview(_controller!)
                  else
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  if (isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: isProcessing ? null : _pickFromGallery,
                              icon: const Icon(Icons.photo_library, color: Colors.white),
                              iconSize: 32,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.close, color: Colors.white, size: 32),
                              ),
                            ),
                           //
                          ],
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: Row(
                          children: [

                            if (_cameras != null && _cameras!.length > 1)
                              IconButton(
                                onPressed: isProcessing ? null : _switchCamera,
                                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                                iconSize: 32,
                              ),
                            if (selectedImages.isNotEmpty)
                              IconButton(
                                onPressed: isProcessing ? null : _submitImages,
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                iconSize: 40,
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: isProcessing || !_isCameraInitialized ? null : _captureImage,
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
                ],
              ),
            )
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

    setState(() {
      _isCameraInitialized = false;
    });

    _controller = CameraController(
      _cameras![newIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await oldController?.dispose();
    await _controller!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      File imageFile = File(image.path);

      setState(() {
        if (!widget.enableMultiSelect) {
          selectedImages.clear();
        }
        selectedImages.add(imageFile);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => isProcessing = true);

    try {
      if (widget.enableMultiSelect) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isEmpty) {
          setState(() => isProcessing = false);
          return;
        }

        for (var image in images) {
          File file = File(image.path);

          if (widget.enableCrop) {
            final croppedFile = await _cropImage(file.path);
            if (croppedFile != null) {
              file = File(croppedFile.path);
            }
          }

          setState(() {
            selectedImages.add(file);
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image == null) {
          setState(() => isProcessing = false);
          return;
        }

        File file = File(image.path);

        if (widget.enableCrop) {
          final croppedFile = await _cropImage(file.path);
          if (croppedFile != null) {
            file = File(croppedFile.path);
          } else {
            file = File(image.path);
          }
        }

        setState(() {
          selectedImages.clear();
          selectedImages.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking from gallery: $e')),
        );
      }
    } finally {
      setState(() => isProcessing = false);
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
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 1.0,
        ),
      ],
    );
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _submitImages() async {
    if (selectedImages.isEmpty) return;

    setState(() => isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      Navigator.of(context).pop(selectedImages);
    }
  }
}

// Image Editor Screen with Crop and Doodle
class ImageEditorScreen extends StatefulWidget {
  final File imageFile;
  final bool enableCrop;

  const ImageEditorScreen({
    super.key,
    required this.imageFile,
    this.enableCrop = true,
  });

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? currentImageFile;
  final GlobalKey _imageKey = GlobalKey();
  List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  Color selectedColor = Colors.red;
  double strokeWidth = 5.0;

  @override
  void initState() {
    super.initState();
    currentImageFile = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Image'),
        iconTheme: Theme.of(context).iconTheme,

        backgroundColor: Colors.black,
        actions: [
          if (widget.enableCrop)
            IconButton(
              icon: const Icon(Icons.crop,color: Colors.white),
              onPressed: _cropImage,
              tooltip: 'Crop',
            ),
          IconButton(
            icon: const Icon(Icons.undo,color: Colors.white),
            onPressed: lines.isEmpty ? null : _undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.check,color: Colors.white),
            onPressed: _saveAndReturn,
            tooltip: 'Done',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _imageKey,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      currentLine = DrawnLine(
                        [details.localPosition],
                        selectedColor,
                        strokeWidth,
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (currentLine != null) {
                        currentLine = DrawnLine(
                          [...currentLine!.points, details.localPosition],
                          currentLine!.color,
                          currentLine!.width,
                        );
                      }
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      if (currentLine != null) {
                        lines.add(currentLine!);
                        currentLine = null;
                      }
                    });
                  },
                  child: CustomPaint(
                    foregroundPainter: DrawingPainter(
                      lines: [...lines, if (currentLine != null) currentLine!],
                    ),
                    child: Image.file(
                      currentImageFile!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Brush Size: ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: strokeWidth,
                        min: 1.0,
                        max: 20.0,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            strokeWidth = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildColorButton(Colors.red),
                      _buildColorButton(Colors.blue),
                      _buildColorButton(Colors.green),
                      _buildColorButton(Colors.yellow),
                      _buildColorButton(Colors.orange),
                      _buildColorButton(Colors.purple),
                      _buildColorButton(Colors.pink),
                      _buildColorButton(Colors.white),
                      _buildColorButton(Colors.black),
                      _buildColorButton(Colors.brown),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  void _undo() {
    setState(() {
      if (lines.isNotEmpty) {
        lines.removeLast();
      }
    });
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: currentImageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
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

    if (croppedFile != null) {
      setState(() {
        currentImageFile = File(croppedFile.path);
        lines.clear(); // Clear drawings after crop
      });
    }
  }

  Future<void> _saveAndReturn() async {
    if (lines.isEmpty) {
      // No doodles, return current image
      Navigator.pop(context, currentImageFile);
      return;
    }

    try {
      // Capture the image with doodles
      final boundary = _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }
}

// Drawing classes
class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine(this.points, this.color, this.width);
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}