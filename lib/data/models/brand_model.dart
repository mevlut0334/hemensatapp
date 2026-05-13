class BrandModel {
  final int id;
  final String name;

  BrandModel({
    required this.id,
    required this.name,
  });

  // JSON'dan Model'e
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'BrandModel{id: $id, name: $name}';
  }
}