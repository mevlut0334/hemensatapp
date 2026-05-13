// lib/data/models/offer_model.dart

class OfferModel {
  final int id;
  final double offerPrice;
  final String? phoneNumber; // ✅ Eklendi
  final String? status; // 'pending', 'accepted', 'rejected' veya null
  final DateTime submittedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final OfferUserModel user;
  final OfferListingModel listing;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferModel({
    required this.id,
    required this.offerPrice,
    this.phoneNumber, // ✅ Eklendi
    this.status,
    required this.submittedAt,
    this.acceptedAt,
    this.rejectedAt,
    required this.user,
    required this.listing,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as int,
      offerPrice: (json['offer_price'] as num).toDouble(),
      phoneNumber: json['phone_number'] as String?, // ✅ Eklendi
      status: json['status'] as String?,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at'] as String) 
          : null,
      rejectedAt: json['rejected_at'] != null 
          ? DateTime.parse(json['rejected_at'] as String) 
          : null,
      user: OfferUserModel.fromJson(json['user'] as Map<String, dynamic>),
      listing: OfferListingModel.fromJson(json['listing'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_price': offerPrice,
      'phone_number': phoneNumber, // ✅ Eklendi
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'user': user.toJson(),
      'listing': listing.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Durum kontrol metodları
  bool get isPending => status == null || status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  // Kopya oluşturma metodu (state güncellemeleri için)
  OfferModel copyWith({
    int? id,
    double? offerPrice,
    String? phoneNumber, // ✅ Eklendi
    String? status,
    DateTime? submittedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    OfferUserModel? user,
    OfferListingModel? listing,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      offerPrice: offerPrice ?? this.offerPrice,
      phoneNumber: phoneNumber ?? this.phoneNumber, // ✅ Eklendi
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      user: user ?? this.user,
      listing: listing ?? this.listing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Teklifi veren kullanıcı bilgileri
class OfferUserModel {
  final int id;
  final String name;
  final String email;

  OfferUserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory OfferUserModel.fromJson(Map<String, dynamic> json) {
    return OfferUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Teklifin yapıldığı ilan bilgileri
class OfferListingModel {
  final int id;
  final String type; // 'RepairListing' veya 'SaleListing'
  final String title;

  OfferListingModel({
    required this.id,
    required this.type,
    required this.title,
  });

  factory OfferListingModel.fromJson(Map<String, dynamic> json) {
    return OfferListingModel(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
    };
  }

  // İlan tipi kontrolleri
  bool get isRepairListing => type == 'RepairListing';
  bool get isSaleListing => type == 'SaleListing';
}

// API'ye gönderilecek teklif oluşturma request modeli
class CreateOfferRequest {
  final double offerPrice;
  final String phoneNumber; // ✅ Eklendi
  final String offerableType;
  final int offerableId;

  CreateOfferRequest({
    required this.offerPrice,
    required this.phoneNumber, // ✅ Eklendi
    required this.offerableType,
    required this.offerableId,
  });

  Map<String, dynamic> toJson() {
    return {
      'offer_price': offerPrice,
      'phone_number': phoneNumber, // ✅ Eklendi
      'offerable_type': offerableType,
      'offerable_id': offerableId,
    };
  }

  // Tamir ilanı için factory
  factory CreateOfferRequest.forRepairListing({
    required double offerPrice,
    required String phoneNumber, // ✅ Eklendi
    required int listingId,
  }) {
    return CreateOfferRequest(
      offerPrice: offerPrice,
      phoneNumber: phoneNumber, // ✅ Eklendi
      offerableType: 'App\\Models\\RepairListing',
      offerableId: listingId,
    );
  }

  // Satış ilanı için factory
  factory CreateOfferRequest.forSaleListing({
    required double offerPrice,
    required String phoneNumber, // ✅ Eklendi
    required int listingId,
  }) {
    return CreateOfferRequest(
      offerPrice: offerPrice,
      phoneNumber: phoneNumber, // ✅ Eklendi
      offerableType: 'App\\Models\\SaleListing',
      offerableId: listingId,
    );
  }
}