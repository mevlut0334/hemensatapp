// lib/presentation/screens/home/sale_listing_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../core/service_locator.dart';
import '../../../data/models/sale_listing_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/sale_listing/sale_listing_detail_bloc.dart';
import '../../widgets/common/subscription_required_dialog.dart';
import '../sale_listing/sale_listing_detail_screen.dart';
import '../offer/create_offer_dialog.dart';

class SaleListingCard extends StatelessWidget {
  final SaleListingModel listing;
  final VoidCallback? onDetailNavigate;

  const SaleListingCard({
    super.key,
    required this.listing,
    this.onDetailNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _truncateText(listing.location.district.name, 20),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              _buildOfferButton(context),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen giriş yapın')));
      return;
    }

    final currentUserId = authState.user.id;
    final isOwner = listing.user.id == currentUserId;
    final isSubscribed = authState.user.isSubscribed;

    final canView = PermissionHelper.canViewListingDetails(
      isSubscribed: isSubscribed,
      isOwner: isOwner,
    );

    if (canView) {
      // ✅ AuthBloc'u koruyarak detay sayfasına git
      final authBloc = context.read<AuthBloc>();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (newContext) => MultiBlocProvider(
            providers: [
              // Mevcut AuthBloc'u paylaş
              BlocProvider<AuthBloc>.value(value: authBloc),
              // Yeni SaleListingDetailBloc oluştur
              BlocProvider<SaleListingDetailBloc>(
                create: (_) => SaleListingDetailBloc(
                  saleListingRepository: sl(),
                  authBloc: authBloc,
                ),
              ),
            ],
            child: SaleListingDetailScreen(
              listingId: listing.id,
              isOwnListing: isOwner,
            ),
          ),
        ),
      );

      onDetailNavigate?.call();
    } else {
      SubscriptionRequiredDialog.showForDetails(context);
    }
  }

  void _handleOfferTap(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen giriş yapın')));
      return;
    }

    final currentUserId = authState.user.id;
    final isOwner = listing.user.id == currentUserId;
    final isSubscribed = authState.user.isSubscribed;

    if (isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kendi ilanınıza teklif veremezsiniz')),
      );
      return;
    }

    final canOffer = PermissionHelper.canMakeOffer(
      isSubscribed: isSubscribed,
      isOwner: isOwner,
    );

    if (canOffer) {
      // Teklif dialog'unu aç
      final result = await CreateOfferDialog.showForSaleListing(
        context: context,
        listingId: listing.id,
        listingTitle: '${listing.brand.name} ${listing.model.name}',
      );

      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teklifiniz başarıyla gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      SubscriptionRequiredDialog.showForOffer(context);
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
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
        child: listing.primaryImage != null || listing.firstImage != null
            ? Image.network(
                ApiConstants.getImageUrl(
                  listing.primaryImage?.path ?? listing.firstImage?.path ?? '',
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
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

  Widget _buildOfferButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleOfferTap(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        'Teklif Ver',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
