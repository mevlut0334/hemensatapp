import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/local_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LocalStorage _localStorage;

  AuthBloc({
    required AuthRepository authRepository,
    required LocalStorage localStorage,
  }) : _authRepository = authRepository,
       _localStorage = localStorage,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRefreshProfileRequested>(_onAuthRefreshProfileRequested);
  }

  // Uygulama açıldığında token kontrolü
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = _localStorage.getToken();
      final userJson = _localStorage.getUserData();

      if (token != null && userJson != null) {
        final user = userModelFromJson(userJson);
        emit(AuthAuthenticated(user: user, token: token));

        // ← YENİ: Arka planda profil bilgilerini yenile
        try {
          final updatedUser = await _authRepository.refreshUserProfile();
          emit(AuthAuthenticated(user: updatedUser, token: token));
        } catch (e) {
          // Profil yenileme başarısız olursa cached veriyle devam et
          // (Kullanıcı deneyimini bozmamak için sessizce hata yut)
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Kayıt işlemi
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(event.registerRequest);

      // Repository zaten kaydediyor, burada tekrar kaydetmeye gerek yok
      // await _localStorage.saveToken(response.token);
      // await _localStorage.saveUserData(userModelToJson(response.user));

      emit(AuthAuthenticated(user: response.user, token: response.token));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Beklenmeyen bir hata oluştu: ${e.toString()}'));
    }
  }

  // Giriş işlemi
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(event.loginRequest);

      // Repository zaten kaydediyor, burada tekrar kaydetmeye gerek yok
      // await _localStorage.saveToken(response.token);
      // await _localStorage.saveUserData(userModelToJson(response.user));

      emit(AuthAuthenticated(user: response.user, token: response.token));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Beklenmeyen bir hata oluştu: ${e.toString()}'));
    }
  }

  // Çıkış işlemi
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Repository logout zaten clearAll() yapıyor
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Hata olsa bile çıkış yap
      await _localStorage.clearAll();
      emit(AuthUnauthenticated());
    }
  }

  // Kullanıcı profilini yenile
  Future<void> _onAuthRefreshProfileRequested(
    AuthRefreshProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Mevcut state'i koru (loading gösterme)
    final currentState = state;

    try {
      final updatedUser = await _authRepository.refreshUserProfile();
      final token = _localStorage.getToken();

      if (token != null) {
        emit(AuthAuthenticated(user: updatedUser, token: token));
      }
    } catch (e) {
      // Hata olursa mevcut state'i koru
      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }
}
