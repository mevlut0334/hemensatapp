import 'user_model.dart';

class AuthResponseModel {
  final String message;
  final UserModel user;
  final String token;

  AuthResponseModel({
    required this.message,
    required this.user,
    required this.token,
  });

  // JSON'dan Model'e
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  // Model'den JSON'a
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'token': token,
    };
  }
}