class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  // Model'den JSON'a (API'ye gönderilecek)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}