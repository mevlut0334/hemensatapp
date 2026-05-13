import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/brand_model.dart';
import '../models/device_model.dart';
import '../models/storage_capacity_model.dart';
import '../models/purchase_source_model.dart';
import '../models/sale_listing_model.dart';

class SaleListingRepository {
  final ApiClient _apiClient;

  SaleListingRepository(this._apiClient);

  // ===== DROPDOWN DATA =====

  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _apiClient.get(ApiConstants.brands);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BrandModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Markalar yüklenemedi');
    }
  }

  Future<List<DeviceModel>> getModelsByBrand(int brandId) async {
    try {
      final response = await _apiClient.get(ApiConstants.modelsByBrand(brandId));
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Modeller yüklenemedi');
    }
  }

  Future<List<StorageCapacityModel>> getStorageCapacities() async {
    try {
      final response = await _apiClient.get(ApiConstants.storageCapacities);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => StorageCapacityModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Depolama kapasiteleri yüklenemedi');
    }
  }

  Future<List<PurchaseSourceModel>> getPurchaseSources() async {
    try {
      final response = await _apiClient.get(ApiConstants.purchaseSources);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PurchaseSourceModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Satın alma kaynakları yüklenemedi');
    }
  }

  // ===== SALE LISTING OPERATIONS =====

  Future<void> createSaleListing({
    required int brandId,
    required int modelId,
    required int storageCapacityId,
    required int purchaseSourceId,
    required int provinceId,
    required int districtId,
    required String phone,
    required String title,
    required String description,
    List<String>? imagePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        'brand_id': brandId,
        'model_id': modelId,
        'storage_capacity_id': storageCapacityId,
        'purchase_source_id': purchaseSourceId,
        'province_id': provinceId,
        'district_id': districtId,
        'phone': phone,
        'title': title,
        'description': description,
      });

      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length && i < 3; i++) {
          formData.files.add(
            MapEntry(
              'images[$i]',
              await MultipartFile.fromFile(
                imagePaths[i],
                filename: 'image_$i.jpg',
              ),
            ),
          );
        }
      }

      await _apiClient.postFormData(ApiConstants.saleListings, formData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan oluşturulamadı: ${e.toString()}');
    }
  }

  // Kullanıcının satış ilanlarını getir (deleted ve inactive filtrelenir)
  Future<List<SaleListingModel>> getMySaleListings() async {
    try {
      final response = await _apiClient.get(ApiConstants.mySaleListings);
      final List<dynamic> data = response.data['data'];
      
      List<SaleListingModel> listings = [];
      for (var item in data) {
        try {
          // Status kontrolü - deleted ve inactive olanları atla
          final status = item['status'] as String?;
          
          if (status == 'deleted' || status == 'inactive') {
            continue;
          }
          
          final listing = SaleListingModel.fromJson(item);
          listings.add(listing);
        } catch (e) {
          // Parse hatası durumunda bu ilanı atla
          continue;
        }
      }
      
      return listings;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlanlar yüklenemedi');
    }
  }

  // Tüm satış ilanlarını getir (sadece active olanlar)
  Future<List<SaleListingModel>> getSaleListings() async {
    try {
      final response = await _apiClient.get(ApiConstants.saleListings);
      final List<dynamic> data = response.data['data'];
      
      List<SaleListingModel> listings = [];
      
      for (var item in data) {
        try {
          // Status kontrolü - sadece active ilanları göster
          final status = item['status'] as String?;
          
          if (status != 'active') {
            continue;
          }
          
          final listing = SaleListingModel.fromJson(item);
          listings.add(listing);
        } catch (e) {
          // Parse hatası durumunda bu ilanı atla
          continue;
        }
      }
      
      return listings;
      
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlanlar yüklenemedi');
    }
  }

  // İlan detayını getir
  Future<SaleListingModel> getSaleListingDetail(int id, {bool? isOwnListing}) async {
    try {
      String endpoint;
      
      if (isOwnListing == true) {
        endpoint = ApiConstants.mySaleListingDetail(id);
      } else {
        endpoint = ApiConstants.saleListingDetail(id);
      }
      
      final response = await _apiClient.get(endpoint);
      
      if (response.data == null) {
        throw ApiException(message: 'API\'den veri alınamadı');
      }
      
      final listing = SaleListingModel.fromJson(response.data);
      
      return listing;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan detayı yüklenemedi: ${e.toString()}');
    }
  }

  // İlanı sil (Backend soft delete yapıyor)
  Future<void> deleteSaleListing(int id) async {
    try {
      await _apiClient.delete(ApiConstants.deleteSaleListing(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan silinemedi');
    }
  }

  // İlanı yayından kaldır
  Future<void> deactivateSaleListing(int id) async {
    try {
      await _apiClient.post(ApiConstants.deactivateSaleListing(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan yayından kaldırılamadı');
    }
  }

  // İlanı satıldı olarak işaretle
  Future<void> markAsSold(int id) async {
    try {
      await _apiClient.post(ApiConstants.markAsSold(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan satıldı olarak işaretlenemedi');
    }
  }
}