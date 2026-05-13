// lib/presentation/screens/sale_listing/widgets/sale_detail_info_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SaleDetailInfoSection extends StatelessWidget {
  final String brand;
  final String model;
  final String title;
  final String description;
  // final String? condition; // ← yorum satırı yapıldı
  final String? storage; // Depolama kapasitesi (opsiyonel)
  final String? purchaseSource; // Nereden alındı (opsiyonel)

  const SaleDetailInfoSection({
    super.key,
    required this.brand,
    required this.model,
    required this.title,
    required this.description,
    // this.condition, // ← yorum satırı yapıldı
    this.storage,
    this.purchaseSource,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marka & Model Kartı
        _buildDeviceInfoCard(),
        const SizedBox(height: 16),
        
        // İlan Başlığı
        _buildTitle(),
        const SizedBox(height: 16),
        
        // İlan Açıklaması
        _buildDescription(),
      ],
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // İkon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Marka & Model Bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Sadece storage veya purchaseSource varsa divider ve bilgiler gösterilecek
          if ((storage != null && storage!.isNotEmpty) || 
              (purchaseSource != null && purchaseSource!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            
            // Depolama, Nereden Alındı
            Column(
              children: [
                // Durum (Condition) - YORUM SATIRI YAPILDI
                // if (condition != null) ...[
                //   _buildInfoRow(
                //     icon: _getConditionIcon(),
                //     iconColor: _getConditionColor(),
                //     label: 'Ürün Durumu',
                //     value: _getConditionText(),
                //     valueColor: _getConditionColor(),
                //   ),
                // ],
                
                // Depolama Kapasitesi (varsa)
                if (storage != null && storage!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.storage,
                    iconColor: AppColors.primary,
                    label: 'Depolama',
                    value: storage!,
                    valueColor: AppColors.textPrimary,
                  ),
                ],
                
                // Nereden Alındı (varsa)
                if (purchaseSource != null && purchaseSource!.isNotEmpty) ...[
                  if (storage != null && storage!.isNotEmpty) 
                    const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppColors.primary,
                    label: 'Nereden Alındı',
                    value: purchaseSource!,
                    valueColor: AppColors.textPrimary,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Açıklama',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // Durum için ikon - YORUM SATIRI YAPILDI
  // IconData _getConditionIcon() {
  //   if (condition == null) return Icons.help_outline;
  //   
  //   switch (condition!.toLowerCase()) {
  //     case 'new':
  //       return Icons.new_releases;
  //     case 'like_new':
  //       return Icons.stars;
  //     case 'good':
  //       return Icons.thumb_up;
  //     case 'fair':
  //       return Icons.check_circle_outline;
  //     case 'poor':
  //       return Icons.warning_amber;
  //     default:
  //       return Icons.help_outline;
  //   }
  // }

  // Durum için renk - YORUM SATIRI YAPILDI
  // Color _getConditionColor() {
  //   if (condition == null) return AppColors.textSecondary;
  //   
  //   switch (condition!.toLowerCase()) {
  //     case 'new':
  //       return const Color(0xFF10B981); // Yeşil
  //     case 'like_new':
  //       return const Color(0xFF059669); // Koyu Yeşil
  //     case 'good':
  //       return const Color(0xFF3B82F6); // Mavi
  //     case 'fair':
  //       return const Color(0xFFF59E0B); // Turuncu
  //     case 'poor':
  //       return const Color(0xFFEF4444); // Kırmızı
  //     default:
  //       return AppColors.textSecondary;
  //   }
  // }

  // Durum için Türkçe metin - YORUM SATIRI YAPILDI
  // String _getConditionText() {
  //   if (condition == null) return 'Belirtilmemiş';
  //   
  //   switch (condition!.toLowerCase()) {
  //     case 'new':
  //       return 'Sıfır';
  //     case 'like_new':
  //       return 'Sıfır Gibi';
  //     case 'good':
  //       return 'İyi';
  //     case 'fair':
  //       return 'Orta';
  //     case 'poor':
  //       return 'Kötü';
  //     default:
  //       return 'Belirtilmemiş';
  //   }
  // }
}