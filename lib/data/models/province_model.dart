class ProvinceModel {
  final int id;
  final String name;
  final String code;
  final String plateCode;
  final String region;
  final bool status;

  ProvinceModel({
    required this.id,
    required this.name,
    required this.code,
    required this.plateCode,
    required this.region,
    required this.status,
  });

  // JSON'dan Model'e
  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      plateCode: json['plate_code']?.toString() ?? json['plateCode']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      status: _parseStatus(json['status']),
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'plate_code': plateCode,
      'region': region,
      'status': status,
    };
  }

  static bool _parseStatus(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return true; // default
  }
}