// lib/data/services/sale_listing_service.dart

import 'package:dio/dio.dart';
import '../models/brand_model.dart';
import '../models/device_model.dart';
import '../models/storage_capacity_model.dart';
import '../models/purchase_source_model.dart';
import '../models/sale_listing_model.dart';

class SaleListingService {
  final Dio _dio;

  SaleListingService(this._dio);

  // ===== DROPDOWN DATA =====

  // Markaları getir
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _dio.get('/brands');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BrandModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Markalar yüklenemedi: $e');
    }
  }

  // Markaya göre modelleri getir
  Future<List<DeviceModel>> getModelsByBrand(int brandId) async {
    try {
      final response = await _dio.get('/brands/$brandId/models');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Modeller yüklenemedi: $e');
    }
  }

  // Depolama kapasitelerini getir
  Future<List<StorageCapacityModel>> getStorageCapacities() async {
    try {
      final response = await _dio.get('/storage-capacities');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => StorageCapacityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Depolama kapasiteleri yüklenemedi: $e');
    }
  }

  // Satın alma kaynaklarını getir
  Future<List<PurchaseSourceModel>> getPurchaseSources() async {
    try {
      final response = await _dio.get('/purchase-sources');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => PurchaseSourceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Satın alma kaynakları yüklenemedi: $e');
    }
  }

  // ===== SALE LISTING OPERATIONS =====

  // Satış ilanı oluştur
  Future<SaleListingModel> createSaleListing({
    required int brandId,
    required int modelId,
    required int storageCapacityId,
    required int purchaseSourceId,
    required int provinceId, // ← YENİ EKLENEN
    required int districtId, // ← YENİ EKLENEN
    required String phone,
    required String title,
    required String description,
    required List<String> imagePaths, // Maksimum 3 adet
  }) async {
    try {
      // FormData oluştur (Multipart için)
      FormData formData = FormData.fromMap({
        'brand_id': brandId,
        'model_id': modelId,
        'storage_capacity_id': storageCapacityId,
        'purchase_source_id': purchaseSourceId,
        'province_id': provinceId, // ← YENİ EKLENEN
        'district_id': districtId, // ← YENİ EKLENEN
        'phone': phone,
        'title': title,
        'description': description,
      });

      // Görselleri ekle (Maksimum 3 adet)
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

      final response = await _dio.post(
        '/sale-listings',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return SaleListingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'İlan oluşturulamadı';
        throw Exception(message);
      }
      throw Exception('Bağlantı hatası: ${e.message}');
    } catch (e) {
      throw Exception('İlan oluşturulamadı: $e');
    }
  }

  // Kullanıcının satış ilanlarını getir
  Future<List<SaleListingModel>> getMySaleListings({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/my-sale-listings',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SaleListingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('İlanlar yüklenemedi: $e');
    }
  }

  // Tüm satış ilanlarını getir (Listeleme için)
  Future<List<SaleListingModel>> getSaleListings({
    int page = 1,
    int perPage = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '/sale-listings',
        queryParameters: {'page': page, 'per_page': perPage, ...?filters},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => SaleListingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('İlanlar yüklenemedi: $e');
    }
  }

  // İlan detayını getir
  Future<SaleListingModel> getSaleListingDetail(int id) async {
    try {
      final response = await _dio.get('/sale-listings/$id');
      return SaleListingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('İlan detayı yüklenemedi: $e');
    }
  }

  // İlanı güncelle
  Future<SaleListingModel> updateSaleListing({
    required int id,
    String? title,
    String? description,
    String? phone,
    int? brandId,
    int? modelId,
    int? storageCapacityId,
    int? purchaseSourceId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null){data['title'] = title;} 
      if (description != null){data['description'] = description;} 
      if (phone != null){data['phone'] = phone;} 
      if (brandId != null){data['brand_id'] = brandId;} 
      if (modelId != null){data['model_id'] = modelId;} 
      if (storageCapacityId != null){data['storage_capacity_id'] = storageCapacityId;}
        
      if (purchaseSourceId != null){data['purchase_source_id'] = purchaseSourceId;}
        

      final response = await _dio.put('/sale-listings/$id', data: data);
      return SaleListingModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('İlan güncellenemedi: $e');
    }
  }

  // İlanı sil
  Future<void> deleteSaleListing(int id) async {
    try {
      await _dio.delete('/sale-listings/$id');
    } catch (e) {
      throw Exception('İlan silinemedi: $e');
    }
  }

  // İlanı yayından kaldır
  Future<void> deactivateSaleListing(int id) async {
    try {
      await _dio.post('/sale-listings/$id/deactivate');
    } catch (e) {
      throw Exception('İlan yayından kaldırılamadı: $e');
    }
  }

  // İlanı satıldı olarak işaretle
  Future<void> markAsSold(int id) async {
    try {
      await _dio.post('/sale-listings/$id/mark-as-sold');
    } catch (e) {
      throw Exception('İlan satıldı olarak işaretlenemedi: $e');
    }
  }
}
