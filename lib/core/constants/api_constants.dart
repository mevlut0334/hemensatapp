class ApiConstants {
  // Base URL - Kendi API URL'ini buraya yaz
  static const String baseUrl = 'https://hemensatapp.com/api';  //http://192.168.111.7:8000/api'  http://89.252.153.225/api
  
  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String userProfile = '/user/profile';

  // Location Endpoints (YENİ EKLENEN)
  static const String provinces = '/location/provinces';
  // District endpoint dinamik olacak: /location/provinces/{provinceId}/districts
  static String districts(int provinceId) => '/location/provinces/$provinceId/districts';

   // Sale Listing Endpoints
  static const String saleListings = '/sale-listings';
  static const String brands = '/sale-listings/brands';
  static String modelsByBrand(int brandId) => '/sale-listings/brands/$brandId/models';
  static const String storageCapacities = '/sale-listings/storage-capacities';
  static const String purchaseSources = '/sale-listings/purchase-sources';
  static const String mySaleListings = '/sale-listings/my';
  static String mySaleListingDetail(int id) => '/sale-listings/my/$id';  // ← YENİ EKLE
  static String saleListingDetail(int id) => '/sale-listings/$id';
  static String deleteSaleListing(int id) => '/sale-listings/$id';
  static String updateSaleListing(int id) => '/sale-listings/$id';
  static String publishSaleListing(int id) => '/sale-listings/$id/publish';
  static String deactivateSaleListing(int id) => '/sale-listings/$id/deactivate';
  static String markAsSold(int id) => '/sale-listings/$id/mark-as-sold';

  // Repair Listing Endpoints
static const String repairListings = '/repair-listings';
static const String repairBrands = '/repair-listings/brands';
static String repairModelsByBrand(int brandId) => '/repair-listings/brands/$brandId/models';
static const String myRepairListings = '/repair-listings/my';
static String myRepairListingDetail(int id) => '/repair-listings/my/$id';  // ← BU SATIRI EKLE
static String repairListingDetail(int id) => '/repair-listings/$id';
static String deleteRepairListing(int id) => '/repair-listings/$id';
static String updateRepairListing(int id) => '/repair-listings/$id';
static String publishRepairListing(int id) => '/repair-listings/$id/publish';
static String completeRepairListing(int id) => '/repair-listings/$id/complete';


// offers endpoint
static const String offersEndpoint = '/offers';
static const String mySentOffersEndpoint = '/offers/my-sent';
static const String myReceivedOffersEndpoint = '/offers/my-received';
static const String listingsEndpoint = '/listings';

/// Görsel URL'sini oluşturur
  static String getImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  
  // baseUrl'den domain'i çıkar
  final domain = baseUrl.replaceAll('/api', '');
  return '$domain/storage/$path';
}

  
  
  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}