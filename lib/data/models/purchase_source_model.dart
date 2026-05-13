// lib/data/models/purchase_source_model.dart

class PurchaseSourceModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  PurchaseSourceModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory PurchaseSourceModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSourceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}