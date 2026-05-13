// lib/core/utils/permission_helper.dart

class PermissionHelper {
  /// İlan detaylarını görebilir mi kontrol eder
  /// 
  /// Kullanıcı şu durumlarda detayları görebilir:
  /// - Kendi ilanıysa (is_owner = true)
  /// - Abone ise (isSubscribed = true)
  static bool canViewListingDetails({
    required bool isSubscribed,
    required bool isOwner,
  }) {
    return isOwner || isSubscribed;
  }

  /// Teklif verebilir mi kontrol eder
  /// 
  /// Kullanıcı şu durumlarda teklif verebilir:
  /// - Kendi ilanı değilse (is_owner = false)
  /// - VE abone ise (isSubscribed = true)
  static bool canMakeOffer({
    required bool isSubscribed,
    required bool isOwner,
  }) {
    return !isOwner && isSubscribed;
  }

  /// İletişim bilgilerini görebilir mi kontrol eder
  static bool canViewContactInfo({
    required bool isSubscribed,
    required bool isOwner,
  }) {
    return isOwner || isSubscribed;
  }
}