import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Token İşlemleri
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  bool hasToken() {
    return _prefs.containsKey(AppConstants.tokenKey);
  }

  // User Data İşlemleri
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(AppConstants.userKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(AppConstants.userKey);
  }

  Future<void> deleteUserData() async {
    await _prefs.remove(AppConstants.userKey);
  }

  bool hasUserData() {  // ← EKLENDI (opsiyonel, ama işe yarayabilir)
    return _prefs.containsKey(AppConstants.userKey);
  }

  // Tümünü Temizle (Logout)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}