// lib/data/models/user_model.dart

import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final int provinceId;      // ← YENİ EKLENEN
  final int districtId;      // ← YENİ EKLENEN
  final String? province;
  final String? district;
  final bool isSubscribed;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.provinceId,     // ← YENİ EKLENEN
    required this.districtId,     // ← YENİ EKLENEN
    required this.isSubscribed,
    this.province,
    this.district,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON'dan Model'e
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      provinceId: json['province_id'] as int,     // ← YENİ EKLENEN
      districtId: json['district_id'] as int,     // ← YENİ EKLENEN
      province: json['province'] as String?,
      district: json['district'] as String?,
      isSubscribed: json['is_subscribed'] == 1 || json['is_subscribed'] == true,  // ← YENİ EKLENEN
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'province_id': provinceId,     // ← YENİ EKLENEN
      'district_id': districtId,     // ← YENİ EKLENEN
      'province': province,
      'district': district,
      'is_subscribed': isSubscribed,  // ← YENİ EKLENEN
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// JSON String dönüşüm fonksiyonları
UserModel userModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UserModel.fromJson(jsonData);
}

String userModelToJson(UserModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}