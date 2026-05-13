class DistrictModel {
  final int id;
  final String name;
  final int provinceId;
  final String provinceName;

  DistrictModel({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.provinceName,
  });

  // JSON'dan Model'e
  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      provinceId: (json['province_id'] as num).toInt(),
      provinceName: json['province_name']?.toString() ?? '',
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'province_id': provinceId,
      'province_name': provinceName,
    };
  }

  @override
  String toString() {
    return 'DistrictModel{id: $id, name: $name, provinceId: $provinceId, provinceName: $provinceName}';
  }
}
