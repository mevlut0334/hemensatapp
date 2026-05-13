import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../data/models/sale_listing_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/sale_listing/sale_listing_detail_bloc.dart';
import '../../../logic/sale_listing/my_sale_listings_bloc.dart';
import '../../../logic/sale_listing/my_sale_listings_event.dart';
import '../sale_listing/sale_listing_detail_screen.dart';

class MySaleListingCard extends StatelessWidget {
  final SaleListingModel listing;

  const MySaleListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _handleCardTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Durum badge'i
                    _buildStatusBadge(),
                    const SizedBox(height: 4),
                    
                    Text(
                      listing.model.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      _truncateText(listing.description, 20),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // İstatistikler (varsa)
                    if (listing.stats != null) _buildStats(),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              _buildDeleteButton(context),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildImage() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _buildPlaceholder(),
    ),
  );
}

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.phone_android,
        size: 40,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData icon;

    switch (listing.status.toLowerCase()) {
      case 'active':
      case 'published':
        badgeColor = const Color(0xFF10B981);
        statusText = 'Aktif';
        icon = Icons.check_circle;
        break;
      case 'sold':
        badgeColor = const Color(0xFF6B7280);
        statusText = 'Satıldı';
        icon = Icons.sell;
        break;
      case 'draft':
        badgeColor = const Color(0xFFF59E0B);
        statusText = 'Taslak';
        icon = Icons.edit;
        break;
      case 'inactive':
        badgeColor = const Color(0xFFEF4444);
        statusText = 'Pasif';
        icon = Icons.pause_circle;
        break;
      default:
        badgeColor = AppColors.textSecondary;
        statusText = listing.status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = listing.stats!;
    return Row(
      children: [
        Icon(
          Icons.local_offer_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${stats.totalOffersCount} Teklif',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () => _handleDeleteTap(context),
      icon: const Icon(Icons.delete_outline),
      color: AppColors.error,
      tooltip: 'İlanı Sil',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  void _handleCardTap(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(
              value: authBloc,
            ),
            BlocProvider<SaleListingDetailBloc>(
              create: (_) => SaleListingDetailBloc(
                saleListingRepository: sl(),
                authBloc: authBloc,
              ),
            ),
          ],
          child: SaleListingDetailScreen(
            listingId: listing.id,
            isOwnListing: true, // Kendi ilanı
          ),
        ),
      ),
    );
  }

  void _handleDeleteTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Bu ilanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MySaleListingsBloc>().add(
                DeleteMySaleListing(listingId: listing.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}