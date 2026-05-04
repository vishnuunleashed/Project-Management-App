class AddMaterialChartRequest {
  final int projectId;
  final int optionId;
  final String optionCode;
  final List<MaterialDetail> detailsList;

  AddMaterialChartRequest({
    required this.projectId,
    required this.optionId,
    required this.optionCode,
    required this.detailsList,
  });
}

class MaterialDetail {
  final String name;
  final String workItem;
  final int qty;
  final int uomId;
  final int reasonId;
  final String reason;
  final String requiredDate;

  // NEW FIELD: Brand reference id
  final int brandId;

  // NEW FIELD: Wastage percentage
  final int wastagePerc;

  MaterialDetail({
    required this.name,
    required this.workItem,
    required this.qty,
    required this.uomId,
    required this.reasonId,
    required this.reason,
    required this.requiredDate,
    required this.brandId,     // NEW
    required this.wastagePerc, // NEW
  });
}
