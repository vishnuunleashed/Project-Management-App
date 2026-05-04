// Quantity Update Dialog
import 'dart:io';

import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
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
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_chart_main_provider.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class QuantityUpdateDialog extends ConsumerStatefulWidget {
  final MaterialRequestModel item;
  final int projectId;
  final void Function()? onSave;

  const QuantityUpdateDialog({
    super.key,
    required this.item,
    required this.projectId,
    required this.onSave,
  });

  @override
  ConsumerState<QuantityUpdateDialog> createState() =>
      _QuantityUpdateDialogState();
}

class _QuantityUpdateDialogState extends ConsumerState<QuantityUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _receivedQtyController;

  @override
  void initState() {
    super.initState();
    _receivedQtyController = TextEditingController(
      text: '',
    );
    Future.microtask(() {
      ref.watch(additionalMaterialMainProvider).recievedData = DateTime.now();
    });
  }

  @override
  void dispose() {
    _receivedQtyController.dispose();
    super.dispose();
  }

  void _pickAndUploadImage(BuildContext context) async {
    final provider =
        ProviderScope.containerOf(context).read(additionalMaterialMainProvider);
    final List<File>? files = await MediaServiceWithCrop.instance.pickImage(
        context,
        enableCrop: true,
        enableMultiSelect: true,
        enableDoodling: true);
    if (files != null) {
      provider.uploadImageFile(files);
    }
  }

  Future<void> _saveQuantityUpdate(
      BuildContext context, AdditionalMaterialMainProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final detail = MaterialQtyUpdateDetail(
        id: widget.item.id ?? 0,
        qty: widget.item.qty ?? 0,
        poQty: widget.item.poIssuedQty ?? 0,
        issuedDate: widget.item.poIssuedDate ?? '',
        expectedDate: widget.item.expectedDeliveryDate ?? '',
        receivedQty: double.tryParse(_receivedQtyController.text) ?? 0,
        receivedDate: DateFormat('dd-MM-yyyy').format(provider.recievedData),
        serialNo: provider.attachmentSeriesNo,
        imagesDtl: provider.images,
        lastmoddate: widget.item.lastModDate,
        balanceqty: widget.item.balanceQty);

    MaterialQtyUpdateRequest request = MaterialQtyUpdateRequest(
      projectId: widget.projectId,
      optionId: widget.item.optionId,
      optionCode: "ADDT_MAT_CHART",
      actionTaken: "RECEIVED_QTY_UPDATE",
      detailsList: [detail],
    );

    provider.updateQuantityAdditionMaterial(
        materialQtyUpdateRequest: request,
        onRequestSuccess: () {
          onSaveDialog(
              context: NavigatorKey.navKey.currentState!.context,
              title: "Success",
              transNo: "",
              icon: Icons.check_circle_outlined,
              iconColor: bayaInfraGreen,
              message: "Quantity updated Successfully",
              onClick: () {
                if (widget.onSave != null) {
                  widget.onSave!();
                }
                provider.initState();
                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
              });
        },
        onRequestFailure: (e) {
          onSaveDialog(
            transNo: "",
            context: NavigatorKey.navKey.currentState!.context,
            title: "Failure",
            message: e.toString(),
            icon: Icons.error,
            iconColor: bayaInfraRed,
            onClick: () =>
                GoRouter.of(NavigatorKey.navKey.currentState!.context).pop(),
          );
        });

    Navigator.pop(context);
  }

  static void onSaveDialog({
    required BuildContext context,
    required String title,
    required String transNo,
    required IconData icon,
    required Color iconColor,
    required String message,
    required VoidCallback onClick,
  }) {
    BaseDialog.show(
        context: context,
        title: title,
        message: message,
        transNo: transNo,
        icon: Icon(
          icon,
          color: iconColor,
          size: 36,
        ),
        actions: [
          BaseElevatedButton(
              borderRadius: 24,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: onClick,
              text: "Ok")
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return BaseConsumer<AdditionalMaterialMainProvider>(
      initState: (context, provider, ref) {
        provider.initDialog();
      },
      provider: additionalMaterialMainProvider,
      builder: (context, provider, ref) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: bayaInfraBlue600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Update Quantity',
                          style:
                              Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Material Name : ',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        widget.item.name ?? '',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Display read-only info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bayaInfraGreyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildReadOnlyRow(
                            'Required Qty', widget.item.qty.toString() ?? ''),
                        const SizedBox(height: 4),
                        _buildReadOnlyRow('Expected Delivery',
                            _formatDate(widget.item.expectedDeliveryDate)),
                        const SizedBox(height: 4),
                        _buildReadOnlyRow(
                            'Balance Qty', widget.item.balanceQty.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BaseTextField(
                    controller: _receivedQtyController,
                    textInputType: TextInputType.number,
                    displayTitle: "Qty",
                    hintText: "0",
                    hintTextNeeded: true,
                    isAutoValidateMode: false,
                    isRequiredField: false,
                    customValidator: (value) {
                      return ((double.tryParse(value ?? '0') ?? 0) >
                              widget.item.balanceQty)
                          ? 'Qty should less than Bal qty'
                          : value == null ||
                                  value.isEmpty ||
                                  value == "0" ||
                                  value == "0.0"
                              ? "Qty cannot be empty or null"
                              : null;
                    },
                    customValidationMessage: "Please enter a quantity",
                  ),
                  const SizedBox(height: 16),

                  CommonDatesPicker(
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2,
                          DateTime.now().month, DateTime.now().day),
                      onChange: (date) {
                        print("Selected date: $date");
                        provider.setRecievedDate(date);
                      },
                      initialDate: provider.recievedData),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attachments (${provider.attachmentUrl.length})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      InkWell(
                        onTap: () {
                          _pickAndUploadImage(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: bayaInfraWhiteColor,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Image",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: bayaInfraWhiteColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (provider.attachmentUrl.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: provider.attachmentUrl.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _buildImageContainer(
                              provider.attachmentUrl[index].url,
                              context,
                              index,
                              provider,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: BaseElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          text: 'Cancel',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BaseElevatedButton(
                          onPressed: () {
                            if (provider.attachmentUrl.isEmpty) {
                              showDialogBox(
                                  context: context,
                                  titleIcon: Icons.warning,
                                  iconColor: Colors.amber,
                                  buttonType: DialogButtonType.okOnly,
                                  action: () {
                                    GoRouter.of(context).pop();
                                  },
                                  title: "Alert",
                                  message: "Upload at least one image.");
                              return;
                            }

                            _saveQuantityUpdate(context, provider);
                          },
                          text: 'Save',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(String? imageUrl, BuildContext context, int index,
      AdditionalMaterialMainProvider provider) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Card(
        elevation: 0.5,
        color: Theme.of(context).cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(
            onTap: () {
              GoRouter.of(context).pushNamed(
                AppRoutes.imageGridChartScreen,
                extra: {
                  "urlList":
                      provider.attachmentUrl.map((e) => e.url ?? "").toList()
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? "",
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.15,
      child: Center(
        child: Icon(
          Icons.attach_file,
          size: 32,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .labelLarge),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
