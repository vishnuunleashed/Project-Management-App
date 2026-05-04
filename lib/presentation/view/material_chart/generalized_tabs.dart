import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/material_chart_provider.dart';
import 'package:interior_design/presentation/view/material_chart/partials/verified_button.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

enum MaterialChartType {
  initial,
  special,
  standard,
}

class MaterialItemCard extends StatelessWidget {
  final MaterialChartType materialType;



  const MaterialItemCard({
    super.key,
    required this.materialType,
   });

  @override
  Widget build(BuildContext context) {
    return BaseConsumer(
      provider: materialChartProvider,
      builder: (context, provider, ref) {
        List<MaterialModel> materials = _getMaterials(provider);


        return RefreshIndicator(
          onRefresh: ()async{
            provider.initValue();
            provider.fetchMaterialChart();

          },
          child: Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    MaterialModel item = materials[index];
                    final isLastItem = (materials.length - 1) == index;
                
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLastItem ? 80 : 0.0,top: 8,right: 8,left: 8),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(context, item),
                                  const SizedBox(height: 8),
                                  _buildDescription(context, item),
                                  const SizedBox(height: 8),
                                  _buildMaterialInfo(context, item),
                                ],
                              ),
                              _buildIgfcSection(context, provider, index, item),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                  visible: (provider.isProjectDepartment || provider.isSuperUser),
                  child: _buildSubmitButton(context)),
            ],
          ),
        );
      },
    );
  }

  List<MaterialModel> _getMaterials(dynamic provider) {
    switch (materialType) {
      case MaterialChartType.initial:
        return provider.initialMaterials;
      case MaterialChartType.special:
        return provider.specialMaterials;
      case MaterialChartType.standard:
        return provider.standardMaterials;
    }
  }

  Widget _buildHeader(BuildContext context, MaterialModel item) {
    final headerText = _getHeaderText(item);

    return Visibility(
      visible: headerText.isNotEmpty,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bayaInfraBlue600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              headerText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: bayaInfraWhiteColor,
              ),
            ),
          ),
          Spacer(),
          Visibility(
              visible: item.isigfcverifiedyn == "Y",
              child: VerifiedBadge())

        ],
      ),
    );
  }

  String _getHeaderText(dynamic item) {
    switch (materialType) {
      case MaterialChartType.initial:
      case MaterialChartType.special:
        return item.boqItem ?? "";
      case MaterialChartType.standard:
        return "";
    }
  }

  Widget _buildDescription(BuildContext context, MaterialModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        item.materialDescription ?? "",
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }



  String formatDate(String dateTimeStr) {
    DateTime? dateTime;

    try {
      dateTime = DateTime.parse(dateTimeStr);
    } catch (_) {}


    if (dateTime == null) {
      final formats = [
        'yyyy-MM-dd',
        'yyyy/MM/dd',
        'dd-MM-yyyy',
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

    final isToday =
        dateTime.year == now.year &&
            dateTime.month == now.month &&
            dateTime.day == now.day;

    if (isToday) {
      return "Today";
    }

    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  Widget _buildMaterialInfo(BuildContext context, MaterialModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.finalizedBrand != null && item.finalizedBrand!.isNotEmpty) ...[
          _buildInfoRow(context, 'Brand', item.finalizedBrand ?? ""),
          const SizedBox(height: 4),
        ],
        _buildInfoRow(context, 'Units', item.units ?? ''),
        const SizedBox(height: 4),
        _buildInfoRow(context, 'BOQ', _getBoqValue(item)),
        Visibility(
            visible: item.requiredDate != null && item.requiredDate!.isNotEmpty,
            child: _buildInfoRow(context, 'Required Date',
              formatDate(item.requiredDate??DateTime.now().toString()),
                ),
            ),

      ],
    );
  }

  String _getBoqValue(dynamic item) {
    switch (materialType) {
      case MaterialChartType.initial:
      case MaterialChartType.special:
        return item.boqQty?.toString() ?? "";
      case MaterialChartType.standard:
        return "";
    }
  }

  Widget _buildIgfcSection(BuildContext context, MaterialChartProvider provider, int index, MaterialModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        materialType == MaterialChartType.standard
            ? _buildQuantityField(
          context: context,
          label: 'Qty : ',
          item: item,
          index: index,
          provider: provider,
          isStandard: true,
        )
            : _buildQuantityField(
          context: context,
          label: 'IGFC Qty : ',
          item: item,
          index: index,
          provider: provider,
          isStandard: false,
        ),
      ],
    );
  }

  Widget _buildQuantityField({
    required BuildContext context,
    required String label,
    required MaterialModel item,
    required int index,
    required MaterialChartProvider provider,
    required bool isStandard,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 14,
            ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.2,
          child: TextFormField(
            initialValue: _getIgfcInitialValue(item),
            enabled: (provider.isProjectDepartment
                || provider.isSuperUser
            ) && (isStandard ? true : item.isigfcverifiedyn == "N"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) {
              _updateIgfcQty(provider, index, value);
            },
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onEditingComplete: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 14,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              isDense: true,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: bayaInfraGreyColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: bayaInfraGreyColor,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: bayaInfraGreyColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getIgfcInitialValue(dynamic item) {
    switch (materialType) {
      case MaterialChartType.initial:
      case MaterialChartType.special:
        return item.igfcQty?.toString() ?? '';
      case MaterialChartType.standard:
        return item.qty?.toString() ?? '';
    }
  }


  void _updateIgfcQty(MaterialChartProvider provider, int index, String value) {
    switch (materialType) {
      case MaterialChartType.initial:
        provider.updateIgfcQtInitialMaterialsy(index, value);
        break;
      case MaterialChartType.special:
        provider.updateIgfcQtySpecialMaterials(index, value);
        break;
      case MaterialChartType.standard:
        provider.updateIgfcQtyStandardMaterials(index, value);
        break;
    }
  }

  Widget _buildSubmitButton(BuildContext context) {
    final provider = ProviderScope.containerOf(context).read(materialChartProvider);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child:Row(
              children: [

                Visibility(
                  visible: materialType != MaterialChartType.standard,
                  child: Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.check_circle,
                        color: bayaInfraGreen,
                        size: 16,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(width: 0.3),
                        ),
                      ),
                      onPressed: () {
                        BaseDialog.show(
                            context: context,
                            title: "Confirm",
                            message: "Do you want to verify the updated IGFC quantities? Once verified, these quantities will be locked.",
                            actions: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(
                                      child: BaseElevatedButton(
                                        fontWeight: null,
                                        borderRadius: 24,
                                        onPressed: () {
                                          GoRouter.of(context).pop();
                                        },
                                        backgroundColor: bayaInfraDisabledColor,
                                        text: "No",
                                      )),
                                  Expanded(
                                      child: BaseElevatedButton(
                                        fontWeight: null,
                                        borderRadius: 24,
                                        backgroundColor: Theme.of(context).primaryColor,
                                        text:"Yes",
                                        onPressed: () {
                                          provider.verifyIGFCQuantities();
                                          GoRouter.of(context).pop();

                                        },
                                      )),

                                ],
                              ),
                            ]);

                        },
                      label: Text('Verify IGFC',style:Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bayaInfraWhiteColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14)
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.check_circle,
                      color: bayaInfraWhiteColor,
                      size: 16,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(width: 0.3),
                      ),
                    ),

                    onPressed: () {

                      provider.updateIGFCQuantity(
                              initialMaterials: provider.initialMaterials,
                              specialMaterials: provider.specialMaterials,
                              standardMaterials: provider.standardMaterials,
                      );



                    },
                    label: Text('Update IGFC',style:Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: bayaInfraWhiteColor,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 14)
                    ),
                  ),
                ),

              ],
            )
          ),
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
          Text(
            '$label : ',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// USAGE EXAMPLES
// ============================================================

// For Initial Materials (with navigation enabled)
class InitialMaterialsScreen extends StatelessWidget {
  const InitialMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialItemCard(
      materialType: MaterialChartType.initial,

    );
  }
}

// For Special Materials
class SpecialMaterialsScreen extends StatelessWidget {
  const SpecialMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialItemCard(
      materialType: MaterialChartType.special,
    );
  }
}

// For Standard Materials
class StandardMaterialsScreen extends StatelessWidget {
  const StandardMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialItemCard(
      materialType: MaterialChartType.standard,
    );
  }
}