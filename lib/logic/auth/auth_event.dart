import 'package:equatable/equatable.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/register_request_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Uygulama başlatıldığında token kontrolü
class AuthCheckRequested extends AuthEvent {}

// Kayıt işlemi
class AuthRegisterRequested extends AuthEvent {
  final RegisterRequestModel registerRequest;

  const AuthRegisterRequested(this.registerRequest);

  @override
  List<Object?> get props => [registerRequest];
}

// Giriş işlemi
class AuthLoginRequested extends AuthEvent {
  final LoginRequestModel loginRequest;

  const AuthLoginRequested(this.loginRequest);

  @override
  List<Object?> get props => [loginRequest];
}

// Çıkış işlemi
class AuthLogoutRequested extends AuthEvent {}

// Profil yenileme işlemi
class AuthRefreshProfileRequested extends AuthEvent {
  const AuthRefreshProfileRequested();
}