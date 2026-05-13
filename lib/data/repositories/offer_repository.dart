// lib/data/repositories/offer_repository.dart

import '../../core/network/api_client.dart';
import '../models/offer_model.dart';

class OfferRepository {
  final ApiClient _apiClient;

  OfferRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Yeni teklif oluşturur
  Future<OfferModel> createOffer(CreateOfferRequest request) async {
    try {
      final response = await _apiClient.post(
        '/offers',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        return OfferModel.fromJson(responseData['offer']);
      } else if (response.statusCode == 403) {
        throw Exception('Bu işlem için abone olmanız gerekiyor');
      } else if (response.statusCode == 400) {
        final responseData = response.data;
        throw Exception(responseData['message'] ?? 'Teklif oluşturulamadı');
      } else {
        throw Exception('Teklif oluşturulurken bir hata oluştu');
      }
    } catch (e) {
      throw Exception('Teklif oluşturma hatası: $e');
    }
  }

  /// Kullanıcının gönderdiği teklifleri getirir
  Future<List<OfferModel>> getMySentOffers() async {
    try {
      final response = await _apiClient.get('/offers/my-sent');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData == null) {
          throw Exception('API response null döndü');
        }
        
        final offersJson = responseData['offers'];
        
        if (offersJson == null) {
          return [];
        }
        
        if (offersJson is! List) {
          throw Exception('Beklenmeyen veri formatı');
        }
        
        final offersList = offersJson.map((json) {
          return OfferModel.fromJson(json);
        }).toList();
        
        return offersList;
        
      } else if (response.statusCode == 403) {
        throw Exception('Bu işlem için abone olmanız gerekiyor');
      } else {
        throw Exception('Teklifler getirilemedi');
      }
    } catch (e) {
      throw Exception('Teklifler getirilirken hata: $e');
    }
  }

  /// Kullanıcının ilanlarına gelen teklifleri getirir
  Future<List<OfferModel>> getMyReceivedOffers() async {
    try {
      final response = await _apiClient.get('/offers/my-received');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData == null) {
          throw Exception('API response null döndü');
        }
        
        final offersJson = responseData['offers'];
        
        if (offersJson == null) {
          return [];
        }
        
        if (offersJson is! List) {
          throw Exception('Beklenmeyen veri formatı');
        }
        
        final offersList = offersJson.map((json) {
          return OfferModel.fromJson(json);
        }).toList();
        
        return offersList;
        
      } else if (response.statusCode == 403) {
        throw Exception('Bu işlem için abone olmanız gerekiyor');
      } else {
        throw Exception('Teklifler getirilemedi');
      }
    } catch (e) {
      throw Exception('Teklifler getirilirken hata: $e');
    }
  }

  /// Belirli bir ilana ait teklifleri getirir (sadece ilan sahibi)
  Future<List<OfferModel>> getOffersForListing({
    required int listingId,
    required String listingType, // 'repair' veya 'sale'
  }) async {
    try {
      final endpoint = '/listings/$listingType/$listingId/offers';
      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final offersJson = responseData['offers'] as List;
        return offersJson.map((json) => OfferModel.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Bu ilanın tekliflerini görme yetkiniz yok');
      } else {
        throw Exception('Teklifler getirilemedi');
      }
    } catch (e) {
      throw Exception('Teklifler getirilirken hata: $e');
    }
  }

  /// Teklifi kabul eder (sadece ilan sahibi)
  Future<bool> acceptOffer(int offerId) async {
    try {
      final response = await _apiClient.patch(
        '/offers/$offerId',
        data: {'action': 'accept'},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['success'] == true;
      } else if (response.statusCode == 403) {
        throw Exception('Bu teklifi kabul etme yetkiniz yok');
      } else if (response.statusCode == 404) {
        throw Exception('Teklif bulunamadı');
      } else {
        final responseData = response.data;
        final errorMessage = responseData['message'] ?? 'Teklif kabul edilemedi';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Teklif kabul edilirken hata: $e');
    }
  }

  /// Teklifi reddeder (sadece ilan sahibi)
  Future<bool> rejectOffer(int offerId) async {
    try {
      final response = await _apiClient.patch(
        '/offers/$offerId',
        data: {'action': 'reject'},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['success'] == true;
      } else if (response.statusCode == 403) {
        throw Exception('Bu teklifi reddetme yetkiniz yok');
      } else if (response.statusCode == 404) {
        throw Exception('Teklif bulunamadı');
      } else {
        final responseData = response.data;
        final errorMessage = responseData['message'] ?? 'Teklif reddedilemedi';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Teklif reddedilirken hata: $e');
    }
  }

  /// Teklifi siler (sadece teklif sahibi, sadece pending durumunda)
  Future<bool> deleteOffer(int offerId) async {
    try {
      final response = await _apiClient.delete('/offers/$offerId');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Bu teklifi silme yetkiniz yok');
      } else if (response.statusCode == 400) {
        throw Exception('Sadece bekleyen teklifler silinebilir');
      } else {
        throw Exception('Teklif silinemedi');
      }
    } catch (e) {
      throw Exception('Teklif silinirken hata: $e');
    }
  }
}