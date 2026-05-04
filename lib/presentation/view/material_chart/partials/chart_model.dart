// Models
class MaterialItem {
  final String boqItem;
  final String description;
  final String brand;
  final String units;
  final String quantity;
  final String requiredDate;
  final String longLead;
  final String leadTime;
  final String category;

  MaterialItem({
    required this.boqItem,
    required this.description,
    required this.brand,
    required this.units,
    required this.quantity,
    required this.requiredDate,
    required this.longLead,
    required this.leadTime,
    required this.category,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      boqItem: json['boq_item'] ?? '',
      description: json['description'] ?? '',
      brand: json['brand'] ?? '',
      units: json['units'] ?? '',
      quantity: json['quantity'] ?? '',
      requiredDate: json['required_date'] ?? '',
      longLead: json['long_lead'] ?? '',
      leadTime: json['lead_time'] ?? '',
      category: json['category'] ?? '',
    );
  }
}