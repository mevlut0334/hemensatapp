import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/province_model.dart';
import '../models/district_model.dart';

class LocationRepository {
  final ApiClient _apiClient;

  LocationRepository(this._apiClient);

  // Tüm illeri getir
  Future<List<ProvinceModel>> getProvinces() async {
    try {
      final response = await _apiClient.get(ApiConstants.provinces);

      final dynamic body = response.data;
      final List<dynamic> data;

      if (body is Map<String, dynamic> && body.containsKey('data')) {
        data = body['data'] as List<dynamic>;
      } else if (body is List) {
        data = body;
      } else {
        throw ApiException(message: 'Geçersiz API yanıtı (provinces)');
      }

      return data.map((json) => ProvinceModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İller yüklenirken bir hata oluştu');
    }
  }

  // Belirli bir ile ait ilçeleri getir
  Future<List<DistrictModel>> getDistricts(int provinceId) async {
    try {
      final response = await _apiClient.get(ApiConstants.districts(provinceId));

      final dynamic body = response.data;
      final List<dynamic> data;

      if (body is Map<String, dynamic> && body.containsKey('data')) {
        data = body['data'] as List<dynamic>;
      } else if (body is List) {
        data = body;
      } else {
        throw ApiException(message: 'Geçersiz API yanıtı (districts)');
      }

      return data.map((json) => DistrictModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'İlçeler yüklenirken bir hata oluştu');
    }
  }
}
