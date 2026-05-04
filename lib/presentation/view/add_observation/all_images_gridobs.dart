import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/provider/add_observation/add_observation_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/image_grid_provider/image_grid_provider.dart';

class ImageGridObsScreen extends StatelessWidget {
  final AddObservationProvider addObservationProvider;
  const ImageGridObsScreen({
    super.key,
    required this.addObservationProvider

  });

  @override
  Widget build(BuildContext context) {
    return BaseView<ImageGridProvider>(
      provider: imageGridProvider,
      initState: (context,provider,ref){
        provider.setParameterForImages(1);
      },
      appBar: CustomAppBar(
        title: const Text("All images"),
      ),
      builder:(context,provider,ref) {

        return Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          controller: provider.gridScrollController,
          itemCount: addObservationProvider.attachmentUrl.length, // show ALL images
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,     // 3 per row vertically
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,  // square tiles
          ),
          itemBuilder: (context, index) {
            AttachmentModel url = addObservationProvider.attachmentUrl[index];
            return GestureDetector(
              onTap: () {

                _openImageViewer(context, addObservationProvider, index);
              },
              child: buildImageContainer(url.url),
            );
          },
        ),
      );
      },
    );
  }

  static Future<void> _openImageViewer(BuildContext context, AddObservationProvider provider, int initialIndex) async {
    try {

      if (provider.attachmentUrl.isNotEmpty) {
        List<String> urls = provider.attachmentUrl.map((e) => e.url).toList();

        if (context.mounted) {
          GoRouter.of(context).pushNamed(
            'imageViewer',
            extra: {
              'images': urls,
              'initialIndex': initialIndex,
            },
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No images found")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load images")),
        );
      }
    }
  }

  Widget buildImageContainer(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey.shade200,
        child: url.isEmpty
            ? Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey.shade500,
          ),
        )
            : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context),
          errorWidget: (context, url, error) => _buildPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return  SizedBox(
      height: MediaQuery.of(context).size.height*0.15,
      child: Center(
        child: Icon(
          Icons.attach_file,
          size: 32,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

}
