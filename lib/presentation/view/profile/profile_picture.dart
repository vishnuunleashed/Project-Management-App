import 'package:base/presentation/theme_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onClickEdit;
  final String fileName;

  const ProfileAvatar({
    super.key,
    required this.onClickEdit,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Avatar - Tappable to view full image
        GestureDetector(
          onTap: () {
            if (fileName.isNotEmpty) {
              _showProfileViewer(context);
            }
          },
          child: Container(
            width: 100, // radius * 2
            height: 100, // radius * 2
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:  Theme.of(context).primaryColor.withOpacity(0.8), // border color
                width: 2, // border width
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: fileName.isNotEmpty ? NetworkImage(fileName) : null,
              child: fileName.isEmpty
                  ?  Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor)
                  : null,
            ),
          )

        ),
        // Edit Button
        Align(
          alignment: Alignment.bottomRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClickEdit,
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color:  Theme.of(context).primaryColor.withOpacity(0.8), width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileViewer(imageUrl: fileName, onClickEdit: onClickEdit,),
      ),
    );
  }
}

class ProfileViewer extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onClickEdit;

  const ProfileViewer({super.key, required this.imageUrl, required this.onClickEdit});

  @override
  State<ProfileViewer> createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable Image
          Center(
            child: GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                });
              },
              onScaleEnd: (details) {
                if (_scale < 1.5) {
                  setState(() {
                    _scale = 1.0;
                  });
                }
              },
              onDoubleTap: () {
                setState(() {
                  _scale = _scale > 1.0 ? 1.0 : 2.0;
                });
              },
              child: Transform.scale(
                scale: _scale,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          // Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Profile Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        widget.onClickEdit();
                        GoRouter.of(context).pop();
                        // Add more options here
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
