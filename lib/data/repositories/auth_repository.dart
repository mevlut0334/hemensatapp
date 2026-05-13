import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../../core/storage/local_storage.dart';
import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepository(this._apiClient, this._localStorage);

  // REGISTER
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Token ve User'ı kaydet
      await _localStorage.saveToken(authResponse.token);
      await _localStorage.saveUserData(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } on ApiException catch (e) {
      // Backend’den gelen mesajı direkt kullanıcıya gönder
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Kayıt işlemi sırasında bir hata oluştu');
    }
  }

  // LOGIN
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Token ve User'ı kaydet
      await _localStorage.saveToken(authResponse.token);
      await _localStorage.saveUserData(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Giriş sırasında bir hata oluştu');
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
      await _localStorage.clearAll();
    } catch (e) {
      await _localStorage.clearAll();
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Çıkış işlemi başarısız oldu');
    }
  }

  // TOKEN VARLIĞI KONTROLÜ
  bool hasToken() {
    return _localStorage.hasToken();
  }

  // KAYITLI USER BİLGİSİNİ AL
  UserModel? getCachedUser() {
    try {
      final userData = _localStorage.getUserData();
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // TOKEN AL
  String? getToken() {
    return _localStorage.getToken();
  }

  // KULLANICI PROFİLİNİ YENİLE (Backend'den güncel bilgiyi al)
Future<UserModel> refreshUserProfile() async {
  try {
    final response = await _apiClient.get(ApiConstants.userProfile);
    final user = UserModel.fromJson(response.data['data']);
    
    // Güncel user bilgisini local'e kaydet
    await _localStorage.saveUserData(jsonEncode(user.toJson()));
    
    return user;
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(message: 'Profil bilgileri yüklenemedi');
  }
}
}
