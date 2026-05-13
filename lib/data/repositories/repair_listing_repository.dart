import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/brand_model.dart';
import '../models/device_model.dart';
import '../models/repair_listing_model.dart';

class RepairListingRepository {
  final ApiClient _apiClient;

  RepairListingRepository(this._apiClient);

  // ===== DROPDOWN DATA =====

  // Markaları getir
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _apiClient.get(ApiConstants.repairBrands);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BrandModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Markalar yüklenemedi');
    }
  }

  // Markaya göre modelleri getir
  Future<List<DeviceModel>> getModelsByBrand(int brandId) async {
    try {
      final response = await _apiClient.get(ApiConstants.repairModelsByBrand(brandId));
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DeviceModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Modeller yüklenemedi');
    }
  }

  // ===== REPAIR LISTING OPERATIONS =====

  // Tamir ilanı oluştur
  Future<void> createRepairListing({
    required int brandId,
    required int modelId,
    required int provinceId,
    required int districtId,
    required String phone,
    required String title,
    required String description,
    List<String>? imagePaths,
  }) async {
    try {
      // FormData oluştur
      final formData = FormData.fromMap({
        'brand_id': brandId,
        'model_id': modelId,
        'province_id': provinceId,
        'district_id': districtId,
        'phone': phone,
        'title': title,
        'description': description,
      });

      // Görselleri ekle (varsa, maksimum 3 adet)
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

      await _apiClient.postFormData(
        ApiConstants.repairListings,
        formData,
      );

    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan oluşturulamadı: ${e.toString()}');
    }
  }

  // Kullanıcının tamir ilanlarını getir (güvenli sürüm)
  Future<List<RepairListingModel>> getMyRepairListings() async {
    try {
      final response = await _apiClient.get(ApiConstants.myRepairListings);

      // Gelen yanıtın yapısı: { message: "...", data: { data: [...] } }
      final dynamic rawData = response.data['data'];
      final List<dynamic> data = (rawData is Map && rawData['data'] is List)
          ? rawData['data']
          : (rawData as List? ?? []);

      // Güvenli JSON dönüşümü
      return data.map((json) {
        try {
          return RepairListingModel.fromJson(json);
        } catch (e) {
          // Parse hatası durumunda boş model döndür
          return RepairListingModel(
            id: json['id'] ?? 0,
            userId: json['user_id'] ?? 0,
            title: json['title'] ?? '',
            description: json['description'] ?? '',
            status: json['status'] ?? '',
            isUrgent: json['is_urgent'] ?? false,
            createdAt: json['created_at'] ?? '',
            brand: RepairListingBrand(id: 0, name: ''),
            model: RepairListingDeviceModel(id: 0, name: ''),
            location: RepairListingLocation(
              province: RepairListingProvince(id: 0, name: ''),
              district: RepairListingDistrict(id: 0, name: ''),
            ),
          );
        }
      }).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlanlar yüklenemedi: ${e.toString()}');
    }
  }

  // Tüm tamir ilanlarını getir
  Future<List<RepairListingModel>> getRepairListings() async {
    try {
      final response = await _apiClient.get(ApiConstants.repairListings);
      final List<dynamic> data = response.data['data'];
      
      return data.map((json) => RepairListingModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlanlar yüklenemedi: ${e.toString()}');
    }
  }

  // İlan detayını getir
  Future<RepairListingModel> getRepairListingDetail(int id, {int? currentUserId, bool? isOwnListing}) async {
    try {
      String endpoint;
      
      // Eğer bu kendi ilanıysa 'my' endpoint'ini kullan
      if (isOwnListing == true) {
        endpoint = ApiConstants.myRepairListingDetail(id);
      } else {
        // Başkasının ilanı için normal endpoint
        endpoint = ApiConstants.repairListingDetail(id);
      }
      
      final response = await _apiClient.get(endpoint);
      
      if (response.data == null) {
        throw ApiException(message: 'Sunucudan boş yanıt alındı');
      }
      
      if (response.data['listing'] == null) {
        throw ApiException(message: 'İlan verisi bulunamadı');
      }
      
      return RepairListingModel.fromJson(response.data['listing']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan detayı yüklenemedi: $e');
    }
  }

  // İlanı sil
  Future<void> deleteRepairListing(int id) async {
    try {
      await _apiClient.delete(ApiConstants.deleteRepairListing(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan silinemedi');
    }
  }

  // İlanı tamamlandı olarak işaretle
  Future<void> completeRepairListing(int id) async {
    try {
      await _apiClient.post(ApiConstants.completeRepairListing(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan tamamlanamadı');
    }
  }

  // İlanı yayınla
  Future<void> publishRepairListing(int id) async {
    try {
      await _apiClient.post(ApiConstants.publishRepairListing(id));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlan yayınlanamadı');
    }
  }
}