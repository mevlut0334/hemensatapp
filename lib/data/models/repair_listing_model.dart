// lib/data/models/repair_listing_model.dart

class RepairListingModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String status;
  final String? phone;
  final bool isUrgent;
  final String? preferredRepairType;
  final String? publishedAt;
  final String? expiresAt;
  final String createdAt;
  final String? updatedAt;

  final RepairListingUser? user;
  final RepairListingBrand brand;
  final RepairListingDeviceModel model;
  final RepairListingLocation location;
  
  final RepairListingImage? primaryImage;
  final RepairListingImage? firstImage;
  final List<RepairListingImage>? images;
  
  final RepairListingStats? stats;
  final RepairListingPermissions? permissions;

  RepairListingModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    this.phone,
    required this.isUrgent,
    this.preferredRepairType,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    this.updatedAt,
    this.user,
    required this.brand,
    required this.model,
    required this.location,
    this.primaryImage,
    this.firstImage,
    this.images,
    this.stats,
    this.permissions,
  });

  factory RepairListingModel.fromJson(Map<String, dynamic> json) {
    return RepairListingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? json['user']?['id'] as int,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'draft',
      phone: json['phone'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      preferredRepairType: json['preferred_repair_type'] as String?,
      publishedAt: json['published_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: json['updated_at'] as String?,
      user: json['user'] != null
          ? RepairListingUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      brand: RepairListingBrand.fromJson(json['brand'] as Map<String, dynamic>),
      model: RepairListingDeviceModel.fromJson(json['model'] as Map<String, dynamic>),
      location: RepairListingLocation.fromJson(json),
      primaryImage: json['primary_image'] != null
          ? RepairListingImage.fromJson(json['primary_image'] as Map<String, dynamic>)
          : null,
      firstImage: json['first_image'] != null
          ? RepairListingImage.fromJson(json['first_image'] as Map<String, dynamic>)
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((img) => RepairListingImage.fromJson(img as Map<String, dynamic>))
              .toList()
          : null,
      stats: json['stats'] != null
          ? RepairListingStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      permissions: json['permissions'] != null
          ? RepairListingPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      'phone': phone,
      'is_urgent': isUrgent,
      'preferred_repair_type': preferredRepairType,
      'published_at': publishedAt,
      'expires_at': expiresAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'brand': brand.toJson(),
      'model': model.toJson(),
      'location': location.toJson(),
      'primary_image': primaryImage?.toJson(),
      'first_image': firstImage?.toJson(),
      'images': images?.map((img) => img.toJson()).toList(),
      'stats': stats?.toJson(),
      'permissions': permissions?.toJson(),
    };
  }
}

class RepairListingUser {
  final int id;
  final String name;
  final String? createdAt;

  RepairListingUser({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory RepairListingUser.fromJson(Map<String, dynamic> json) {
    return RepairListingUser(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }
}

class RepairListingBrand {
  final int id;
  final String name;

  RepairListingBrand({
    required this.id,
    required this.name,
  });

  factory RepairListingBrand.fromJson(Map<String, dynamic> json) {
    return RepairListingBrand(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RepairListingDeviceModel {
  final int id;
  final String name;

  RepairListingDeviceModel({
    required this.id,
    required this.name,
  });

  factory RepairListingDeviceModel.fromJson(Map<String, dynamic> json) {
    return RepairListingDeviceModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RepairListingLocation {
  final RepairListingProvince province;
  final RepairListingDistrict district;

  RepairListingLocation({
    required this.province,
    required this.district,
  });

  factory RepairListingLocation.fromJson(Map<String, dynamic> json) {
    return RepairListingLocation(
      province: RepairListingProvince.fromJson(json['province'] as Map<String, dynamic>),
      district: RepairListingDistrict.fromJson(json['district'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province': province.toJson(),
      'district': district.toJson(),
    };
  }
}

class RepairListingProvince {
  final int id;
  final String name;

  RepairListingProvince({
    required this.id,
    required this.name,
  });

  factory RepairListingProvince.fromJson(Map<String, dynamic> json) {
    return RepairListingProvince(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RepairListingDistrict {
  final int id;
  final String name;

  RepairListingDistrict({
    required this.id,
    required this.name,
  });

  factory RepairListingDistrict.fromJson(Map<String, dynamic> json) {
    return RepairListingDistrict(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class RepairListingImage {
  final int id;
  final String path;
  final String fullUrl;
  final String? thumbnailUrl;
  final bool isPrimary;
  final int displayOrder;

  RepairListingImage({
    required this.id,
    required this.path,
    required this.fullUrl,
    this.thumbnailUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory RepairListingImage.fromJson(Map<String, dynamic> json) {
    final String path = (json['path'] as String?) ?? '';
    final String? providedFullUrl = json['full_url'] as String?;
    
    // Backend'den full_url gelmediyse, base URL ile birleştir
    final String fullUrl = providedFullUrl ?? 
        (path.isNotEmpty ? 'http://192.168.111.7:8000/storage/$path' : '');
    
    return RepairListingImage(
      id: json['id'] as int,
      path: path,
      fullUrl: fullUrl,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'full_url': fullUrl,
      'thumbnail_url': thumbnailUrl,
      'is_primary': isPrimary,
      'display_order': displayOrder,
    };
  }
}

class RepairListingStats {
  final int totalOffersCount;
  final int imagesCount;
  final int viewCount;

  RepairListingStats({
    required this.totalOffersCount,
    required this.imagesCount,
    required this.viewCount,
  });

  factory RepairListingStats.fromJson(Map<String, dynamic> json) {
    return RepairListingStats(
      totalOffersCount: json['total_offers_count'] as int? ?? 0,
      imagesCount: json['images_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_offers_count': totalOffersCount,
      'images_count': imagesCount,
      'view_count': viewCount,
    };
  }
}

class RepairListingPermissions {
  final bool canViewDetails;
  final bool canContact;
  final bool isOwner;

  RepairListingPermissions({
    required this.canViewDetails,
    required this.canContact,
    required this.isOwner,
  });

  factory RepairListingPermissions.fromJson(Map<String, dynamic> json) {
    return RepairListingPermissions(
      canViewDetails: json['can_view_details'] as bool? ?? false,
      canContact: json['can_contact'] as bool? ?? false,
      isOwner: json['is_owner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_view_details': canViewDetails,
      'can_contact': canContact,
      'is_owner': isOwner,
    };
  }
}