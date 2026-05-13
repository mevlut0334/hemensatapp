// lib/presentation/widgets/common/app_drawer.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/web_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/auth/auth_state.dart';
import '../../screens/profile/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Profil Header
            _buildProfileHeader(context),

            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.border),

            // Menü İçeriği
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profilim
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'PROFİLİM',
                    onTap: () {
                      
                      
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  // Abone Ol
                  _buildMenuItem(
                    icon: Icons.card_giftcard,
                    title: 'ABONE OL',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(WebConstants.subscriptionUrl);
                    },
                  ),

                  // SSS
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'SSS',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(WebConstants.faqUrl);
                    },
                  ),

                  // Hakkımızda
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'HAKKIMIZDA',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(WebConstants.aboutUrl);
                    },
                  ),

                  // Gizlilik Politikası
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'GİZLİLİK POLİTİKASI',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(WebConstants.privacyPolicyUrl);
                    },
                  ),

                  // KVKK
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'KVKK',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(WebConstants.kvkkUrl);
                    },
                  ),

                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.border),

                  // Çıkış Yap
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'ÇIKIŞ YAP',
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(context); // Drawer'ı kapat
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profil Header Widget - BlocBuilder ile user bilgisi alınacak
  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Kullanıcı';
        String userEmail = '';

        // AuthState'den user bilgisini al
        if (state is AuthAuthenticated) {
          userName = state.user.name;
          userEmail = state.user.email;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: AppColors.primary),
          child: Row(
            children: [
              // Circle Avatar - images/logo.png kullanılacak
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Kullanıcı Adı ve Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userEmail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Normal Menü Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  // URL açma metodu
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Hata durumunda sessizce geç veya log tutabilirsin
      debugPrint('Could not launch $urlString');
    }
  }
}
