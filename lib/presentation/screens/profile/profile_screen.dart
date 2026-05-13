// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/models/province_model.dart';
import '../../../data/models/district_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocationRepository _locationRepository = sl<LocationRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(
              child: Text('Kullanıcı bilgisi bulunamadı'),
            );
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profil Avatar
                _buildProfileAvatar(),
                
                const SizedBox(height: 24),

                // Kullanıcı Bilgileri Kartı
                _buildInfoCard(
                  title: 'Kişisel Bilgiler',
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Ad Soyad',
                      value: user.name,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'E-posta',
                      value: user.email,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Konum Bilgileri Kartı - FutureBuilder ile
                FutureBuilder<Map<String, String>>(
                  future: _fetchLocationNames(user.provinceId, user.districtId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildInfoCard(
                        title: 'Konum Bilgileri',
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildInfoCard(
                        title: 'Konum Bilgileri',
                        children: [
                          _buildInfoRow(
                            icon: Icons.location_city_outlined,
                            label: 'İl',
                            value: user.province ?? 'Belirtilmemiş',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.place_outlined,
                            label: 'İlçe',
                            value: user.district ?? 'Belirtilmemiş',
                          ),
                        ],
                      );
                    }

                    final locationData = snapshot.data ?? {};
                    final provinceName = locationData['province'] ?? user.province ?? 'Belirtilmemiş';
                    final districtName = locationData['district'] ?? user.district ?? 'Belirtilmemiş';

                    return _buildInfoCard(
                      title: 'Konum Bilgileri',
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'İl',
                          value: provinceName,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.place_outlined,
                          label: 'İlçe',
                          value: districtName,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // İl ve İlçe isimlerini çek
  Future<Map<String, String>> _fetchLocationNames(int provinceId, int districtId) async {
    try {
      // İlleri çek
      final provinces = await _locationRepository.getProvinces();
      final province = provinces.firstWhere(
        (p) => p.id == provinceId,
        orElse: () => ProvinceModel(
          id: provinceId,
          name: 'Bilinmiyor',
          code: '',
          plateCode: '',
          region: '',
          status: false,
        ),
      );

      // İlçeleri çek
      final districts = await _locationRepository.getDistricts(provinceId);
      final district = districts.firstWhere(
        (d) => d.id == districtId,
        orElse: () => DistrictModel(
          id: districtId,
          name: 'Bilinmiyor',
          provinceId: provinceId,
          provinceName: province.name,
        ),
      );

      return {
        'province': province.name,
        'district': district.name,
      };
    } catch (e) {
      return {};
    }
  }

  // Profil Avatar Widget
  Widget _buildProfileAvatar() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        child: const Icon(
          Icons.person,
          size: 50,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Bilgi Kartı Widget
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Bilgi Satırı Widget
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}