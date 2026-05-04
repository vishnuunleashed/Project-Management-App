import 'dart:io';

import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/camera_with_crop_single_image.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_chart_main_provider.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/qty_main_widget.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class AdditionalMaterialCard extends ConsumerWidget {
  final VoidCallback? onRefresh;
  final List<MaterialRequestModel> list;

  const AdditionalMaterialCard({
    super.key,
    this.onRefresh,
    required this.list,
  });




  @override
  Widget build(BuildContext context,ref) {
    ref.watch(additionalMaterialMainProvider);
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh!();
      },
      child: BaseConsumer(
        provider: additionalMaterialMainProvider,
        builder: (context, provider, ref) {
          provider.listController = ScrollController();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: provider.listController,
                  itemCount: list.length,
                  itemBuilder: (context, index) {

                    return InkWell(
                      onTap: (){

                        GoRouter.of(context).pushNamed(
                            AppRoutes.additionalMaterialDetailView, extra: {'transid':  list[index].id,"projectid": list[index].projectId});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                        child: Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(context,  list[index]),
                                    const SizedBox(height: 8),
                                    _buildMaterialInfo(context,  list[index]),

                                    _buildAttachmentsSection(context,  list[index], provider),
                                   
                                      SizedBox(height: 8),
                                     _buildActionButtons(context,  list[index], provider),
                                    
                                  ],
                                ),
                                _buildMaterialStatusBadge(context,  list[index].approvalStatus ?? "")
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MaterialRequestModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Item - Bold and bigger
              if (item.workItem.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.27,
                      child: Text(
                        "Work Item",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Theme.of(context).scaffoldBackgroundColor
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              bayaInfraBlue50!,
                                              bayaInfraBlue100!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Work Item",
                                                style: Theme.of(context).textTheme.titleLarge
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, color: Colors.grey),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: 200,
                                            maxHeight: 600,
                                          ),
                                          child: SingleChildScrollView(
                                            physics: AlwaysScrollableScrollPhysics(),
                                            child: Text(
                                              item.workItem,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          ": ${item.workItem}",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                  ],
                ),

              // Material Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.27,
                    child: Text(
                      "Material Name",
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).scaffoldBackgroundColor
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            bayaInfraBlue50!,
                                            bayaInfraBlue100!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              "Material Name",
                                              style: Theme.of(context).textTheme.titleLarge
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.grey),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: 200,
                                          maxHeight: 600,
                                        ),
                                        child: SingleChildScrollView(
                                          physics: AlwaysScrollableScrollPhysics(),
                                          child: Text(
                                            item.name,
                                            style: Theme.of(context).textTheme.titleMedium
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        ": ${item.name}" ?? "",
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildMaterialStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor = bayaInfraWhiteColor;
    IconData icon;
    String displayStatus = status;

    switch (status.toUpperCase()) {
      case "PENDING":
        backgroundColor = Color(0xFFFF8C00);
        icon = Icons.pending_outlined;
        displayStatus = "PENDING";
        break;
      case "APPROVED":
        backgroundColor = Color(0xff28A745);
        icon = Icons.check_circle_outline;
        displayStatus = "APPROVED";
        break;
      case "SEND_BACK":
      case "SENDBACK":
        backgroundColor = Color(0xffC9B037);
        icon = Icons.replay;
        displayStatus = "SEND BACK";
        break;
      case "REJECTED":
        backgroundColor = Color(0xffDC3545);
        icon = Icons.cancel_outlined;
        displayStatus = "REJECTED";
        break;
      case "RESUBMITTED":
        backgroundColor =  Color(0xff007BFF);
        icon = Icons.refresh;
        displayStatus = "RESUBMITTED";
        break;
      default:
        backgroundColor = bayaInfraGreyColor;
        icon = Icons.help_outline;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "";

    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(dateTimeStr);
    } catch (_) {}

    if (dateTime == null) {
      final formats = [
        'dd-MM-yyyy',
        'yyyy-MM-dd',
        'yyyy/MM/dd',
        'dd/MM/yyyy',
        'MMM dd, yyyy',
        'dd MMM yyyy',
      ];

      for (final format in formats) {
        try {
          dateTime = DateFormat(format).parseStrict(dateTimeStr);
          break;
        } catch (_) {}
      }
    }

    if (dateTime == null) {
      return dateTimeStr;
    }

    final now = DateTime.now();
    final isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (isToday) {
      return "Today";
    }

    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  Widget _buildMaterialInfo(BuildContext context, MaterialRequestModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        if (item.brand.isNotEmpty) ...[
          _buildInfoRow(context, 'Brand', item.brand),
          const SizedBox(height: 3),
        ],
        // UOM
        if ( item.uom.isNotEmpty) ...[
          _buildInfoRow(context, 'UOM', item.uom),
          const SizedBox(height: 3),
        ],
        // Quantity
        _buildInfoRow(context, 'Req Qty', item.qty.toString()),
        const SizedBox(height: 3),
        _buildInfoRow(context, 'Bal Qty', item.balanceQty.toString()),
        const SizedBox(height: 3),
        // Required Date (Previously Requested Date)
        if (item.requiredDate.isNotEmpty)
          _buildInfoRow(
            context,
            'Req. Date',
            formatDate(item.requiredDate),
          ),
        // Reason (if present)
        if (item.reason.isNotEmpty) ...[
          _buildInfoRow(context, 'Reason', item.reason),
        ],
      ],
    );
  }



  Widget _buildActionButtons(BuildContext context, MaterialRequestModel item,AdditionalMaterialMainProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center   ,
      children: [
        SizedBox(width: 8),
        Expanded(
          child: Visibility(
            visible: item.poIssuedYn == "Y" &&  item.balanceQty > 0
                     && (provider.isSuperUser || provider.isProjectDepartment),  
            child: OutlinedButton.icon(
              onPressed: () {
                _showQuantityUpdateDialog(context, item,provider);
              },
              icon: Icon(
                Icons.edit,
                size: 16,
                color: bayaInfraWhiteColor,
              ),
              label: Text(
                'Update Quantity',
                style: TextStyle(
                  fontSize: 11,
                  color: bayaInfraWhiteColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                side: BorderSide(color: bayaInfraBlue600!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
             SizedBox(width: 8),
        Expanded(
          child: Visibility(
            visible:  item.approvalStatus.toUpperCase() == "APPROVED"  && item.balanceQty > 0 && item.receivedQty != item.balanceQty,
            child: ElevatedButton.icon(
              onPressed: () {
                GoRouter.of(context)
                    .pushNamed(AppRoutes.addSupportRequest,
                    extra: {
                      "isFromMaterialChart":true,
                      "recordId":item.id,
                      'projectId' : item.projectId
                    });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                side: BorderSide(color: bayaInfraBlue600!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                Icons.add,
                size: 16,
                color: bayaInfraWhiteColor,
              ),
              label: Text(
                "Raise Support Request",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: bayaInfraWhiteColor,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),

           SizedBox(width: 8),

      ],
    );
  }


  void _showQuantityUpdateDialog(
      BuildContext context, MaterialRequestModel item, AdditionalMaterialMainProvider provider) {


    showDialog(
      context: context,
      builder: (context) => QuantityUpdateDialog(
        item: item,
        projectId: provider.projectId,
        onSave: (){},
      ),
    );
  }



  Widget _buildAttachmentsSection(
      BuildContext context, MaterialRequestModel item,AdditionalMaterialMainProvider provider) {

    if (item.attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file,
              size: 16,
              color: bayaInfraBlue600,
            ),
            const SizedBox(width: 4),
            Text(
              'Attachments (${item.attachments.length})',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 13,
                color: bayaInfraBlue600,
              ),
            ),
          ],
        ),

        if (item.attachments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: item.attachments.length > 4
                  ? 4
                  : item.attachments.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _openImageViewer(context,item , provider, index);
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildImageContainer(
                      item.attachments.map((e) => e.attachmentPhysicalNameUrl).toList(),
                      context,
                      index,
                      provider,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }



  static Future<void> _openImageViewer(BuildContext context,MaterialRequestModel item,AdditionalMaterialMainProvider provider, int initialIndex) async {
    try {

      print("entered___ ");
      if (item.attachments.isNotEmpty) {
        final urls = item.attachments.map((e) => e.attachmentPhysicalNameUrl).toList();
        print("Urls --- $urls");

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

  Widget _buildImageContainer(List<String> imageUrl, BuildContext context,int index,AdditionalMaterialMainProvider provider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        elevation: 0.5,
        color: Theme.of(context).cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: (){
              GoRouter.of(context).pushNamed(
                AppRoutes.imageGridChartScreen,
                extra: {
                  "urlList": imageUrl
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(context),
              errorWidget: (context, url, error) => _buildPlaceholder(context),
            ),
          ),
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



  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Visibility(
      visible: value.isNotEmpty,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Text(
              '$label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Text(
              ": $value",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}




// Attachment Viewer Dialog
class AttachmentViewerDialog extends StatefulWidget {
  final List<AttachmentModel> urls;
  final int initialIndex;

  const AttachmentViewerDialog({
    super.key,
    required this.urls,
    required this.initialIndex,
  });

  @override
  State<AttachmentViewerDialog> createState() => _AttachmentViewerDialogState();
}

class _AttachmentViewerDialogState extends State<AttachmentViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                      Text(
                        'Attachment ${_currentIndex + 1} of ${widget.urls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Image Viewer
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.urls.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          widget.urls[index].url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                    null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Navigation dots
              if (widget.urls.length > 1)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.urls.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? Colors.white
                              : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Navigation arrows
          if (widget.urls.length > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            if (_currentIndex < widget.urls.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

