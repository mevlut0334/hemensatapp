class StorageCapacityModel {
  final int id;
  final String name; // capacity değerini name olarak kullanacağız (dropdown için)

  StorageCapacityModel({
    required this.id,
    required this.name,
  });

  // JSON'dan Model'e
  factory StorageCapacityModel.fromJson(Map<String, dynamic> json) {
    return StorageCapacityModel(
      id: (json['id'] as num).toInt(),
      name: json['capacity']?.toString() ?? '', // API'den gelen 'capacity' değerini 'name' olarak kullan
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'capacity': name, // API'ye gönderirken 'capacity' olarak gönder
    };
  }

  @override
  String toString() {
    return 'StorageCapacityModel{id: $id, name: $name}';
  }
}