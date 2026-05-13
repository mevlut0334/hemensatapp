import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/location/location_cubit.dart';
import '../../../logic/location/location_state.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/province_model.dart';
import '../../../data/models/district_model.dart';
import '../../../data/models/register_request_model.dart';
import '../../../core/service_locator.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  ProvinceModel? _selectedProvince;
  DistrictModel? _selectedDistrict;

  late final LocationCubit locationCubit;

  @override
  void initState() {
    super.initState();
    locationCubit = sl<LocationCubit>();
    locationCubit.fetchProvinces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    locationCubit.close();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final registerRequest = RegisterRequestModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
        provinceId: _selectedProvince!.id,
        districtId: _selectedDistrict!.id,
      );

      debugPrint('Register Request: ${registerRequest.toJson()}');

      // context.read kullanarak AuthBloc'a eriş
      context.read<AuthBloc>().add(AuthRegisterRequested(registerRequest));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/splash');
        },
      ),
      title: const Text("Kayıt Ol"),
    ),
      body: BlocListener<AuthBloc, AuthState>(
        // bloc parametresi kaldırıldı - context'ten otomatik bulacak
        listener: (context, authState) {
          if (authState is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (authState is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt başarılı! Hoş geldiniz.'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          // bloc parametresi kaldırıldı - context'ten otomatik bulacak
          builder: (context, authState) {
            final isAuthLoading = authState is AuthLoading;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<LocationCubit, LocationState>(
                bloc: locationCubit,
                builder: (context, locationState) {
                  if (locationState.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(locationState.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  }

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: "İsim"),
                            enabled: !isAuthLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'İsim gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: "E-posta"),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isAuthLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'E-posta gerekli';
                              }
                              if (!value.contains('@')) {
                                return 'Geçerli bir e-posta girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: "Şifre"),
                            obscureText: true,
                            enabled: !isAuthLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              if (value.length < 8) {
                                return 'Şifre en az 8 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordConfirmationController,
                            decoration: const InputDecoration(labelText: "Şifre Tekrar"),
                            obscureText: true,
                            enabled: !isAuthLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre tekrarı gerekli';
                              }
                              if (value != _passwordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // İL DROPDOWN
                          DropdownButtonFormField<ProvinceModel>(
                            initialValue: _selectedProvince,
                            hint: const Text('İl Seçiniz'),
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: locationState.provinces.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (locationState.isLoading || isAuthLoading) 
                                ? null 
                                : (value) {
                              setState(() {
                                _selectedProvince = value;
                                _selectedDistrict = null;
                              });
                              if (value != null) {
                                locationCubit.fetchDistricts(value.id);
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen il seçiniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          
                          // İLÇE DROPDOWN
                          DropdownButtonFormField<DistrictModel>(
                            initialValue: _selectedDistrict,
                            hint: const Text('İlçe Seçiniz'),
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            items: locationState.districts.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(d.name),
                              );
                            }).toList(),
                            onChanged: (locationState.isLoading || isAuthLoading) 
                                ? null 
                                : (value) {
                              setState(() {
                                _selectedDistrict = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen ilçe seçiniz';
                              }
                              return null;
                            },
                          ),
                          
                          if (locationState.isLoading || isAuthLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (locationState.isLoading || isAuthLoading) 
                                  ? null 
                                  : _handleRegister,
                              child: isAuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text("Kayıt Ol"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Zaten hesabınız var mı? '),
                              GestureDetector(
                                onTap: isAuthLoading ? null : () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    color: isAuthLoading ? Colors.grey : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}