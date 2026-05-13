import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// İlk durum - Kontrol ediliyor
class AuthInitial extends AuthState {}

// Yükleniyor durumu
class AuthLoading extends AuthState {}

// Giriş yapılmış durum
class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

// Giriş yapılmamış durum
class AuthUnauthenticated extends AuthState {}

// Hata durumu
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}