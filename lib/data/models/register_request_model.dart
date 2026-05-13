class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final int provinceId;
  final int districtId;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.provinceId,
    required this.districtId,
  });

  // Model'den JSON'a (API'ye gönderilecek)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'province_id': provinceId,
      'district_id': districtId,
    };
  }
}