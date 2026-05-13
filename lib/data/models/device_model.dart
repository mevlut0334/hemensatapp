class DeviceModel {
  final int id;
  final String name;
  final int brandId;

  DeviceModel({
    required this.id,
    required this.name,
    required this.brandId,
  });

  // JSON'dan Model'e
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      brandId: (json['brand_id'] as num).toInt(),
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand_id': brandId,
    };
  }

  @override
  String toString() {
    return 'DeviceModel{id: $id, name: $name, brandId: $brandId}';
  }
}