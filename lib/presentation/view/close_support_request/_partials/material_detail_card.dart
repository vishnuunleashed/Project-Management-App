
import 'package:base/presentation/theme_config.dart';

import 'package:flutter/material.dart';

import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';

import 'package:intl/intl.dart' as intl;

class AdditionalMaterialHeaderCard extends StatelessWidget {
  final AdditionalMaterialJson item;
  final bool isProjectDepartment;
  final VoidCallback onUpdateQty;

  const AdditionalMaterialHeaderCard({
    super.key,
    required this.item,
    required this.onUpdateQty,
    required this.isProjectDepartment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  "Additional Material Support",
                  style: textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (item.workitem?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: _label(textTheme, "Work Item"),
                    ),
                    Expanded(
                      child: _value(textTheme, item.workitem!),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: _label(textTheme, "Description"),
                ),
                Expanded(
                  child: _value(textTheme, item.name ?? ""),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: _label(textTheme, "Received Qty"),
                ),
                Expanded(
                  child: _value(
                    textTheme,
                    "${item.receivedqty} ${item.uom ?? ""}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: _label(textTheme, "Required Qty"),
                ),
                Expanded(
                  child: _value(
                    textTheme,
                    "${item.qty} ${item.uom ?? ""}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: _label(textTheme, "Required Date"),
                ),
                Expanded(
                  child:
                      _value(textTheme, _formatDate(item.requireddate ?? "")),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (item.reason?.isNotEmpty == true)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: _label(textTheme, "Reason"),
                  ),
                  Expanded(
                    child: _value(textTheme, item.reason!),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            if (item.poissuedyn == "Y" && isProjectDepartment)
              _buildActionButtons(context)
          ],
        ),
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) return "";
    return intl.DateFormat.yMMMd().format(parsedDate); // e.g. Oct 14, 2024
    
  }

  Widget _buildActionButtons(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        onUpdateQty();
      },
      icon: Icon(
        Icons.edit,
        size: 16,
        color: bayaInfraWhiteColor,
      ),
      label: Text(
        'Receive Quantity',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: bayaInfraWhiteColor),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        side: BorderSide(color: bayaInfraBlue600!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _label(TextTheme textTheme, String text) {
    return Text(
      "$text ",
      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _value(TextTheme textTheme, String text) {
    return Text(
      ": $text",
      style: textTheme.titleSmall,
    );
  }
}
