import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;
  final LocalStorage _localStorage;

  ApiClient(this._localStorage) : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = ApiConstants.connectionTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Interceptor ekle
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Token varsa header'a ekle
          final token = _localStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // POST Request
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // POST FormData Request (Dosya yükleme için)
  Future<Response> postFormData(String path, FormData formData) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // PUT Request
  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // PATCH Request
  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // DELETE Request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'Beklenmeyen hata: $e');
    }
  }

  // Hata Yönetimi
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Bağlantı zaman aşımına uğradı',
          statusCode: null,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Veri gönderimi zaman aşımına uğradı',
          statusCode: null,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Veri alımı zaman aşımına uğradı',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        String message = 'Bir hata oluştu';
        
        if (responseData != null) {
          if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'] ?? 'Bir hata oluştu';
          } else {
            message = 'Sunucu hatası: $statusCode';
          }
        }
        
        return ApiException(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return ApiException(message: 'İstek iptal edildi');

      case DioExceptionType.connectionError:
        return ApiException(message: 'İnternet bağlantınızı kontrol edin');

      case DioExceptionType.badCertificate:
        return ApiException(message: 'Güvenlik sertifikası hatası');

      case DioExceptionType.unknown:
        final message = error.message ?? 'Bilinmeyen hata';
        return ApiException(
          message: 'Bilinmeyen bir hata oluştu: $message',
        );
    }
  }
}