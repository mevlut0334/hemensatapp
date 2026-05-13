// lib/data/models/sale_listing_model.dart

class SaleListingModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? phone;
  final String? publishedAt;
  final String? expiresAt;
  final String createdAt;
  final String updatedAt;

  final SaleListingUser user;
  final SaleListingBrand brand;
  final SaleListingDeviceModel model;
  final SaleListingStorage storage;
  final SaleListingPurchaseSource? purchaseSource;
  final SaleListingLocation location;

  final SaleListingImage? primaryImage;
  final SaleListingImage? firstImage;
  final List<SaleListingImage>? images;

  final SaleListingStats? stats;

  SaleListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.phone,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.brand,
    required this.model,
    required this.storage,
    this.purchaseSource,
    required this.location,
    this.primaryImage,
    this.firstImage,
    this.images,
    this.stats,
  });

  factory SaleListingModel.fromJson(Map<String, dynamic> json) {
    return SaleListingModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'draft',
      phone: json['phone'] as String?,
      publishedAt: json['published_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',

      // USER: Liste endpoint'inde 'user' objesi, /my endpoint'inde sadece 'user_id'
      user: json['user'] != null
          ? SaleListingUser.fromJson(json['user'] as Map<String, dynamic>)
          : SaleListingUser(
              id: (json['user_id'] as int?) ?? (json['id'] as int? ?? -1),
              name: 'Benim İlanım',
            ),

      // BRAND: Liste endpoint'inde 'brand' objesi, /my endpoint'inde sadece 'brand_id'
      brand: json['brand'] != null
          ? SaleListingBrand.fromJson(json['brand'] as Map<String, dynamic>)
          : SaleListingBrand(
              id: json['brand_id'] as int? ?? -1,
              name: 'Bilinmeyen Marka',
            ),

      // MODEL: Liste endpoint'inde 'model', detay endpoint'inde 'device_model', /my endpoint'inde sadece 'model_id'
      model: json['model'] != null
          ? SaleListingDeviceModel.fromJson(
              json['model'] as Map<String, dynamic>,
            )
          : (json['device_model'] != null
                ? SaleListingDeviceModel.fromJson(
                    json['device_model'] as Map<String, dynamic>,
                  )
                : (json['model_id'] != null
                      ? SaleListingDeviceModel(
                          id: json['model_id'] as int,
                          name: 'Bilinmeyen Model',
                        )
                      : throw Exception('Model bilgisi bulunamadı'))),

      // STORAGE: Liste endpoint'inde 'storage', detay endpoint'inde 'storage_capacity', /my endpoint'inde sadece 'storage_capacity_id'
      storage: json['storage'] != null
          ? SaleListingStorage.fromJson(json['storage'] as Map<String, dynamic>)
          : (json['storage_capacity'] != null
                ? SaleListingStorage.fromJson(
                    json['storage_capacity'] as Map<String, dynamic>,
                  )
                : (json['storage_capacity_id'] != null
                      ? SaleListingStorage(
                          id: json['storage_capacity_id'] as int,
                          name: null,
                          capacity: 'Bilinmeyen',
                        )
                      : throw Exception('Storage bilgisi bulunamadı'))),

      // PURCHASE SOURCE: Liste endpoint'inde 'purchase_source' objesi, /my endpoint'inde sadece 'purchase_source_id'
      purchaseSource: json['purchase_source'] != null
          ? SaleListingPurchaseSource.fromJson(
              json['purchase_source'] as Map<String, dynamic>,
            )
          : (json['purchase_source_id'] != null
                ? SaleListingPurchaseSource(
                    id: json['purchase_source_id'] as int,
                    name: 'Bilinmeyen Kaynak',
                  )
                : null),

      // LOCATION: Liste endpoint'inde 'location' nested, detay endpoint'inde 'province' ve 'district' ayrı, /my endpoint'inde sadece ID'ler
      location: json['location'] != null
          ? SaleListingLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : (json['province'] != null && json['district'] != null
                ? SaleListingLocation(
                    province: SaleListingProvince.fromJson(
                      json['province'] as Map<String, dynamic>,
                    ),
                    district: SaleListingDistrict.fromJson(
                      json['district'] as Map<String, dynamic>,
                    ),
                  )
                : (json['province_id'] != null && json['district_id'] != null
                      ? SaleListingLocation(
                          province: SaleListingProvince(
                            id: json['province_id'] as int,
                            name: 'Bilinmeyen İl',
                          ),
                          district: SaleListingDistrict(
                            id: json['district_id'] as int,
                            name: 'Bilinmeyen İlçe',
                          ),
                        )
                      : throw Exception(
                          'Location bilgisi bulunamadı: location=${json['location']}, province=${json['province']}, province_id=${json['province_id']}',
                        ))),

      primaryImage: json['primary_image'] != null
          ? SaleListingImage.fromJson(
              json['primary_image'] as Map<String, dynamic>,
            )
          : null,
      firstImage: json['first_image'] != null
          ? SaleListingImage.fromJson(
              json['first_image'] as Map<String, dynamic>,
            )
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
                .map(
                  (img) =>
                      SaleListingImage.fromJson(img as Map<String, dynamic>),
                )
                .toList()
          : null,
      stats: json['stats'] != null
          ? SaleListingStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'phone': phone,
      'published_at': publishedAt,
      'expires_at': expiresAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user.toJson(),
      'brand': brand.toJson(),
      'model': model.toJson(),
      'storage': storage.toJson(),
      'purchase_source': purchaseSource?.toJson(),
      'location': location.toJson(),
      'primary_image': primaryImage?.toJson(),
      'first_image': firstImage?.toJson(),
      'images': images?.map((img) => img.toJson()).toList(),
      'stats': stats?.toJson(),
    };
  }
}

class SaleListingUser {
  final int id;
  final String name;
  final String? createdAt;

  SaleListingUser({required this.id, required this.name, this.createdAt});

  factory SaleListingUser.fromJson(Map<String, dynamic> json) {
    return SaleListingUser(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt};
  }
}

class SaleListingBrand {
  final int id;
  final String name;

  SaleListingBrand({required this.id, required this.name});

  factory SaleListingBrand.fromJson(Map<String, dynamic> json) {
    return SaleListingBrand(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SaleListingDeviceModel {
  final int id;
  final String name;

  SaleListingDeviceModel({required this.id, required this.name});

  factory SaleListingDeviceModel.fromJson(Map<String, dynamic> json) {
    return SaleListingDeviceModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SaleListingStorage {
  final int id;
  final String? name;
  final String capacity;

  SaleListingStorage({required this.id, this.name, required this.capacity});

  factory SaleListingStorage.fromJson(Map<String, dynamic> json) {
    return SaleListingStorage(
      id: json['id'],
      name: json['name'] as String?,
      capacity: json['capacity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'capacity': capacity};
  }
}

class SaleListingPurchaseSource {
  final int id;
  final String name;

  SaleListingPurchaseSource({required this.id, required this.name});

  factory SaleListingPurchaseSource.fromJson(Map<String, dynamic> json) {
    return SaleListingPurchaseSource(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SaleListingLocation {
  final SaleListingProvince province;
  final SaleListingDistrict district;

  SaleListingLocation({required this.province, required this.district});

  factory SaleListingLocation.fromJson(Map<String, dynamic> json) {
    return SaleListingLocation(
      province: SaleListingProvince.fromJson(json['province']),
      district: SaleListingDistrict.fromJson(json['district']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'province': province.toJson(), 'district': district.toJson()};
  }
}

class SaleListingProvince {
  final int id;
  final String name;

  SaleListingProvince({required this.id, required this.name});

  factory SaleListingProvince.fromJson(Map<String, dynamic> json) {
    return SaleListingProvince(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SaleListingDistrict {
  final int id;
  final String name;

  SaleListingDistrict({required this.id, required this.name});

  factory SaleListingDistrict.fromJson(Map<String, dynamic> json) {
    return SaleListingDistrict(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SaleListingImage {
  final int id;
  final String path;
  final String url;
  final String? thumbnailUrl;
  final bool isPrimary;
  final int order;

  SaleListingImage({
    required this.id,
    required this.path,
    required this.url,
    this.thumbnailUrl,
    required this.isPrimary,
    required this.order,
  });

  factory SaleListingImage.fromJson(Map<String, dynamic> json) {
    final String path = (json['path'] as String?) ?? '';
    final String? providedUrl = json['url'] as String?;

    final String url =
        providedUrl ??
        (path.isNotEmpty ? 'http://192.168.111.7:8000/storage/$path' : '');

    return SaleListingImage(
      id: json['id'],
      path: path,
      url: url,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'is_primary': isPrimary,
      'order': order,
    };
  }

  String get fullUrl => url;
  int get displayOrder => order;
}

class SaleListingStats {
  final int totalOffersCount;
  final int pendingOffersCount;
  final int acceptedOffersCount;
  final int rejectedOffersCount;
  final double highestOfferPrice;
  final double latestOfferPrice;
  final double averageOfferPrice;
  final String? lastOfferAt;
  final int? imagesCount;

  SaleListingStats({
    required this.totalOffersCount,
    required this.pendingOffersCount,
    required this.acceptedOffersCount,
    required this.rejectedOffersCount,
    required this.highestOfferPrice,
    required this.latestOfferPrice,
    required this.averageOfferPrice,
    this.lastOfferAt,
    this.imagesCount,
  });

  factory SaleListingStats.fromJson(Map<String, dynamic> json) {
    return SaleListingStats(
      totalOffersCount: json['total_offers_count'] ?? 0,
      pendingOffersCount: json['pending_offers_count'] ?? 0,
      acceptedOffersCount: json['accepted_offers_count'] ?? 0,
      rejectedOffersCount: json['rejected_offers_count'] ?? 0,
      highestOfferPrice: (json['highest_offer_price'] ?? 0).toDouble(),
      latestOfferPrice: (json['latest_offer_price'] ?? 0).toDouble(),
      averageOfferPrice: (json['average_offer_price'] ?? 0).toDouble(),
      lastOfferAt: json['last_offer_at'],
      imagesCount: json['images_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_offers_count': totalOffersCount,
      'pending_offers_count': pendingOffersCount,
      'accepted_offers_count': acceptedOffersCount,
      'rejected_offers_count': rejectedOffersCount,
      'highest_offer_price': highestOfferPrice,
      'latest_offer_price': latestOfferPrice,
      'average_offer_price': averageOfferPrice,
      'last_offer_at': lastOfferAt,
      'images_count': imagesCount,
    };
  }
}