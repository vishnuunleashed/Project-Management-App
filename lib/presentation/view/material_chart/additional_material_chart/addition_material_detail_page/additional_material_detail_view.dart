import 'dart:io';

import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_text_field.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_detail_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_detail_provider.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/qty_main_widget.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class AdditionalMaterialDetailView extends StatelessWidget {
  const AdditionalMaterialDetailView({
    super.key,
  });

  static void _submitForm(
    ProjectApprovalModel statusModel,
    AdditionalMaterialDetailProvider provider,
    BuildContext context,
  ) {
    provider.updateStatus(
      statusModel: statusModel,
      onSuccess: (message) {
        onSaveDialog(
          context: context,
          title: "Success",
          transNo: "",
          icon: Icons.check_circle_outlined,
          iconColor: bayaInfraGreen,
          message: "Status updated successfully",
          onClick: () {
            //this is where i pop from
            GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
            GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
          },
        );
      },
      onFailure: (e) {
        onSaveDialog(
          context: context,
          transNo: "",
          title: "Failure",
          message: e.toString(),
          icon: Icons.error,
          iconColor: bayaInfraRed,
          onClick: () =>
              GoRouter.of(NavigatorKey.navKey.currentState!.context).pop(),
        );
      },
    );
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
      context: NavigatorKey.navKey.currentState!.context,
      title: title,
      message: message,
      transNo: transNo,
      icon: Icon(icon, color: iconColor, size: 36),
      actions: [
        BaseElevatedButton(
          borderRadius: 24,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: onClick,
          text: "Ok",
        )
      ],
    );
  }

  bool hasMatchingSubtype({
    required List<MaterialRequestModel>? reasonRoleList,
    required MaterialRequestModel item,
  }) {
    if (reasonRoleList == null || reasonRoleList.isEmpty) {
      return false;
    }

    final Set<int> subtypeSet =
        reasonRoleList.map((e) => e.reasonTypeId ?? 0).toSet();

    return subtypeSet.contains(item.reasonTypeId);
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

  @override
  Widget build(BuildContext context) {
    return BaseView(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        provider.setParameters(
          extra: extra,
        );
        if(extra!["notificationid"] != null){
          provider.setNotificationId(extra["notificationid"]);
        }else if(extra["notificationId"] != null){
          provider.setNotificationId(extra["notificationId"]);
        }
      },
      provider: additionalMaterialDetailProvider,
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            elevation: 0,
            title: Text(
              'Material Details',
            ),
            action: [
              // Status Badge Section
              Visibility(
                visible: provider.materialItem.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: _buildMaterialStatusBadge(context, provider),
                  ),
                ),
              ),
              Visibility(
                visible: provider.materialItem.isNotEmpty &&
                    provider.materialItem.first.supportReqYn == "Y",
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        GoRouter.of(context).pushNamed(
                            AppRoutes.taskAgainstSupportListPage,
                            extra: {
                              'materialItemId': provider.materialItem.first.id,
                              'projectId':
                                  provider.materialItem.first.projectId,
                            });
                      },
                      icon: Icon(
                        Icons.support_agent,
                        color: Theme.of(context).iconTheme.color,
                      )),
                ),
              )
            ],
          ),

          body: (provider.materialItem.isEmpty)
              ? EmptyListView(
                  emptyText: "Detail view is empty",

                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            _buildActionButtons(
                                context, provider.materialItem.first, provider),
                            const SizedBox(height: 8),

                            // Work Item Section
                            _buildSectionCard(
                              context,
                              title: "Work Item",
                              child: _buildDetailRow(
                                context,
                                label: "",
                                value:
                                    provider.materialItem.first.workItem ?? "",
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Material Information Section
                            _buildSectionCard(
                              context,
                              title: "Material Information",
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    label: "Material Name",
                                    value:
                                        provider.materialItem.first.name ?? "",
                                    isExpandable: true,
                                  ),
                                  if ((provider.materialItem.first.brand ?? "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Brand",
                                      value:
                                          provider.materialItem.first.brand ??
                                              "",
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Quantity Details Section
                            _buildSectionCard(
                              context,
                              title: "Quantity Details",
                              child: Column(
                                children: [
                                  _buildDetailRowEditable(
                                    context,
                                    label: 'Requested Qty',
                                    value: provider.qtyController.text,
                                    isEditable: provider.materialItem.first
                                            .approvalStatus ==
                                        "SEND_BACK",
                                    controller: provider.qtyController,
                                  ),
                                  if (provider.materialItem.first.balanceQty >
                                      0) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Balance Qty",
                                      value: (provider.materialItem.first
                                                  .balanceQty ??
                                              0)
                                          .toString(),
                                    ),
                                  ],
                                  if ((provider.materialItem.first.uom ?? "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "UOM",
                                      value:
                                          provider.materialItem.first.uom ?? "",
                                    ),
                                  ],
                                  if (provider.materialItem.first.wastagePerc >
                                      0) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Wastage %",
                                      value:
                                          "${provider.materialItem.first.wastagePerc}%",
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Request Details Section
                            _buildSectionCard(
                              context,
                              title: "Request Details",
                              child: Column(
                                children: [
                                  if ((provider.materialItem.first
                                              .requiredDate ??
                                          "")
                                      .isNotEmpty)
                                    _buildDetailRow(
                                      context,
                                      label: "Required Date",
                                      value: formatDate(provider
                                          .materialItem.first.requiredDate),
                                    ),
                                  if ((provider.materialItem.first
                                              .requestedByName ??
                                          "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Required By",
                                      value: provider.materialItem.first
                                              .requestedByName ??
                                          "",
                                    ),
                                  ],
                                  if ((provider.materialItem.first.reasonType ??
                                          "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Reason Type",
                                      value: provider
                                              .materialItem.first.reasonType ??
                                          "",
                                    ),
                                  ],
                                  if ((provider.materialItem.first.reason ?? "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Reason",
                                      value:
                                          provider.materialItem.first.reason ??
                                              "",
                                      isExpandable: true,
                                    ),
                                  ],
                                  if ((provider.materialItem.first.remarks ??
                                          "")
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      context,
                                      label: "Remarks",
                                      value: (provider
                                                  .materialItem.first.remarks ??
                                              0)
                                          .toString(),
                                    ),
                                    const SizedBox(height: 8),
                                  ]
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Approval Details Section (if approved)
                            if (provider.isApproved()) ...[
                              _buildSectionCard(
                                context,
                                title: "Approval Details",
                                child: Column(
                                  children: [
                                    if ((provider.materialItem.first
                                                .approvedByUser ??
                                            "")
                                        .isNotEmpty)
                                      _buildDetailRow(
                                        context,
                                        label: "Approved By",
                                        value: provider.materialItem.first
                                                .approvedByUser ??
                                            "",
                                      ),
                                    if ((provider.materialItem.first
                                                .approvalDate ??
                                            "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "Approval Date",
                                        value: formatDate(provider
                                            .materialItem.first.approvalDate),
                                      ),
                                    ],
                                    if ((provider.materialItem.first.remarks ??
                                            "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "Remarks",
                                        value: provider
                                                .materialItem.first.remarks ??
                                            "",
                                        isExpandable: true,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // PO Details Section (if PO issued)
                            if (provider.isPOIssued()) ...[
                              _buildSectionCard(
                                context,
                                title: "PO Details",
                                child: Column(
                                  children: [
                                    if ((provider.materialItem.first
                                                .poIssuedByUser ??
                                            "")
                                        .isNotEmpty)
                                      _buildDetailRow(
                                        context,
                                        label: "PO Issued By",
                                        value: provider.materialItem.first
                                                .poIssuedByUser ??
                                            "",
                                      ),
                                    if ((provider.materialItem.first
                                                .poIssuedDate ??
                                            "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "PO Issued Date",
                                        value: formatDate(provider
                                            .materialItem.first.poIssuedDate),
                                      ),
                                    ],
                                    if (provider
                                            .materialItem.first.poIssuedQty !=
                                        null) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "PO Issued Qty",
                                        value: provider
                                            .materialItem.first.poIssuedQty
                                            .toString(),
                                      ),
                                    ],
                                    if ((provider.materialItem.first
                                                .expectedDeliveryDate ??
                                            "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "Expected Delivery",
                                        value: formatDate(provider.materialItem
                                            .first.expectedDeliveryDate),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            if (provider.materialItem.first.receivedYn ==
                                "Y") ...[
                              _buildSectionCard(
                                context,
                                title: "Received Details",
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                      context,
                                      label: "Received Qty",
                                      value: (provider.materialItem.first
                                                  .receivedQty ??
                                              0)
                                          .toString(),
                                    ),

                                    if ((provider.materialItem.first
                                                .lastReceivedDate ??
                                            "")
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "Last Received Date",
                                        value: formatDate(provider.materialItem
                                            .first.lastReceivedDate),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        context,
                                        label: "Balance Qty",
                                        value: (provider.materialItem.first
                                                    .balanceQty ??
                                                0)
                                            .toString(),
                                      ),
                                    ],

                                    // Attachments Section
                                    if (provider.hasAttachments()) ...[
                                      _buildSectionCard(
                                        context,
                                        title:
                                            "Attachments (${provider.getAttachmentCount()})",
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemCount: provider.materialItem.first
                                                  .attachments?.length ??
                                              0,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                _openImageViewer(
                                                    context, provider, index);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: _buildImageContainer(
                                                  provider.getAttachmentUrls(),
                                                  context,
                                                  index,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          // Bottom Action Buttons
          bottomSheet: provider.hasAnyActionButton()
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        if (provider.showApproveBtn)
                          Expanded(
                            child: BaseElevatedButton(
                              onPressed: () {
                                _handleApprove(context,
                                    provider.materialItem.first, provider);
                              },
                              text: 'Approve',
                              backgroundColor: bayaInfraPaleGreen,
                            ),
                          ),
                        if (provider.showApproveBtn &&
                            (provider.showRejectBtn || provider.showReworkBtn))
                          const SizedBox(width: 8),
                        if (provider.showRejectBtn)
                          Expanded(
                            child: BaseElevatedButton(
                              onPressed: () {
                                _handleReject(context,
                                    provider.materialItem.first, provider);
                              },
                              text: 'Reject',
                              backgroundColor: bayaInfraRed,
                            ),
                          ),
                        if (provider.showRejectBtn && provider.showReworkBtn)
                          const SizedBox(width: 8),
                        if (provider.showReworkBtn)
                          Expanded(
                            child: BaseElevatedButton(
                              onPressed: () {
                                _handleSendForRework(context,
                                    provider.materialItem.first, provider);
                              },
                              text: 'Rework',
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        if (provider.showResubmitBtn)
                          Expanded(
                            child: BaseElevatedButton(
                              onPressed: () {
                                _handleResubmit(context,
                                    provider.materialItem.first, provider);
                              },
                              text: 'Resubmit',
                              backgroundColor: bayaInfraBlue600!,
                              // icon: Icons.refresh,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDetailRowEditable(
    BuildContext context, {
    required String label,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                  ),
            ),
          ),
        Expanded(
          child: isEditable && controller != null
              ? _editableQuantityField(
                  context,
                  label: label,
                  controller: controller,
                )
              : Text(
                  label.isEmpty ? value : ": $value",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                      ),
                ),
        ),
      ],
    );
  }

  Widget _editableQuantityField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
           ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isExpandable = false,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                  ),
            ),
          ),
        Expanded(
          child: isExpandable && value.length > 50
              ? InkWell(
                  onTap: () {
                    _showExpandedText(context, label, value);
                  },
                  child: Text(
                    label.isEmpty ? value : ": $value",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
                  label.isEmpty ? value : ": $value",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
        ),
      ],
    );
  }

  void _showExpandedText(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bayaInfraBlue50!,
                        bayaInfraBlue100!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 100,
                      maxHeight: 400,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 14,
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
  }

  Widget _buildMaterialStatusBadge(
      BuildContext context, AdditionalMaterialDetailProvider provider) {
    Color backgroundColor = provider.getStatusColor();
    Color textColor = bayaInfraWhiteColor;
    IconData icon = provider.getStatusIcon();
    String displayStatus = provider.getDisplayStatus();

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MaterialRequestModel item,
      AdditionalMaterialDetailProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 8),
        Expanded(
          child: Visibility(
            visible: item.poIssuedYn == "Y" &&
                item.balanceQty > 0 &&
                (provider.isSuperUser || provider.isProjectDepartment),
            child: OutlinedButton.icon(
              onPressed: () {
                _showQuantityUpdateDialog(context, item, provider);
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
                  fontWeight: FontWeight.w600,
                  color: bayaInfraWhiteColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
            visible: item.approvalStatus.toUpperCase() == "APPROVED" &&
                item.balanceQty > 0 &&
                item.receivedQty != item.balanceQty,
            child: ElevatedButton.icon(
              onPressed: () {
                GoRouter.of(context).pushNamed(AppRoutes.addSupportRequest,
                    extra: {
                      "isFromMaterialChart": true,
                      "recordId": item.id,
                      'projectId': item.projectId
                    });
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  void _showQuantityUpdateDialog(BuildContext context,
      MaterialRequestModel item, AdditionalMaterialDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => QuantityUpdateDialog(
        item: item,
        projectId: item.projectId ?? 0,
        onSave: () {
          print("entering___ ");
          provider.initializeWithItem();
        },
      ),
    );
  }

  static Future<void> _openImageViewer(
    BuildContext context,
    AdditionalMaterialDetailProvider provider,
    int initialIndex,
  ) async {
    try {
      if (provider.hasAttachments()) {
        final urls = provider.getAttachmentUrls();

        if (context.mounted) {
          GoRouter.of(context).pushNamed(
            'imageViewer',
            extra: {
              'images': urls,
              'initialIndex': initialIndex,
            },
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

  Widget _buildImageContainer(
      List<String> imageUrl, BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl[index],
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.attach_file,
        size: 32,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  // Handle Approve Action
  void _handleApprove(BuildContext context, MaterialRequestModel item,
      AdditionalMaterialDetailProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Confirm Status Change',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text("Are you sure you want to 'Approve' this record?",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitForm(
                ProjectApprovalModel(
                  rowid: item.id,
                  status: "APPROVED",
                  remarks: "",
                  qty: double.tryParse(provider.qtyController.text),
                  lastModDate: item.lastModDate,
                  projectid: provider.projectId,
                ),
                provider,
                context,
              );
            },
            child: Text('Approve',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600, color: bayaInfraWhiteColor)),
          ),
        ],
      ),
    );
  }

  // Handle Reject Action
  void _handleReject(BuildContext context, MaterialRequestModel item,
      AdditionalMaterialDetailProvider provider) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Confirmation',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selected status :',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ' Reject',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a remarks';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _submitForm(
                  ProjectApprovalModel(
                    rowid: item.id,
                    status: "REJECTED",
                    qty: double.tryParse(provider.qtyController.text),
                    remarks: reasonController.text.trim(),
                    lastModDate: item.lastModDate,
                    projectid: provider.projectId,
                  ),
                  provider,
                  context,
                );
              }
            },
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500, color: bayaInfraWhiteColor),
            ),
          ),
        ],
      ),
    );
  }

  // Handle Send for Rework Action
  void _handleSendForRework(BuildContext context, MaterialRequestModel item,
      AdditionalMaterialDetailProvider provider) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title:
            Text('Confirmation', style: Theme.of(context).textTheme.titleLarge),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selected status :',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ' Send For Rework',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter remarks';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _submitForm(
                  ProjectApprovalModel(
                    rowid: item.id,
                    status: "SEND_BACK",
                    qty: double.tryParse(provider.qtyController.text),
                    remarks: remarksController.text.trim(),
                    lastModDate: item.lastModDate,
                    projectid: provider.projectId,
                  ),
                  provider,
                  context,
                );
              }
            },
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600, color: bayaInfraWhiteColor),
            ),
          ),
        ],
      ),
    );
  }

  // Handle Resubmit Action
  void _handleResubmit(BuildContext context, MaterialRequestModel item,
      AdditionalMaterialDetailProvider provider) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Confirmation',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Selected status :',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ' Resubmit',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Remarks',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter remarks';
                  }
                  return null;
                },
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _submitForm(
                  ProjectApprovalModel(
                    rowid: item.id,
                    status: "RESUBMITTED",
                    remarks: remarksController.text.trim(),
                    qty: double.tryParse(provider.qtyController.text),
                    lastModDate: item.lastModDate,
                    projectid: provider.projectId,
                  ),
                  provider,
                  context,
                );
              }
            },
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600, color: bayaInfraWhiteColor),
            ),
          ),
        ],
      ),
    );
  }
}
