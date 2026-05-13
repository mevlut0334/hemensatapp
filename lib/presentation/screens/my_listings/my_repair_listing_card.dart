// lib/presentation/screens/my_listings/my_repair_listing_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/core/service_locator.dart';
import 'package:hemensatapp/core/theme/app_colors.dart';
import 'package:hemensatapp/data/models/repair_listing_model.dart';
import 'package:hemensatapp/data/repositories/repair_listing_repository.dart';
import 'package:hemensatapp/logic/auth/auth_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/repair_listing_detail_bloc.dart';
import 'package:hemensatapp/presentation/screens/repair_listing/repair_listing_detail_screen.dart';

class MyRepairListingCard extends StatelessWidget {
  final RepairListingModel listing;
  final VoidCallback onDeletePressed;

  const MyRepairListingCard({
    super.key,
    required this.listing,
    required this.onDeletePressed,
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
        onTap: () => _navigateToDetail(context),
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
                    _buildStatusBadge(),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      text: '${listing.location.province.name} / ${listing.location.district.name}',
                    ),
                  ],
                ),
              ),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => RepairListingDetailBloc(
            repairListingRepository: sl<RepairListingRepository>(),
            authBloc: context.read<AuthBloc>(),
          ),
          child: RepairListingDetailScreen(
            listingId: listing.id,
            isOwnListing: true, // Kendi ilanı olduğunu belirtiyoruz
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
        child: (listing.primaryImage != null || listing.firstImage != null)
            ? Image.network(
                listing.primaryImage?.thumbnailUrl ??
                    listing.firstImage?.thumbnailUrl ??
                    listing.primaryImage?.fullUrl ??
                    listing.firstImage?.fullUrl ??
                    '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(listing.status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getStatusText(listing.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(listing.status),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          tooltip: 'İlanı Sil',
          onPressed: () => _showDeleteConfirmationDialog(context),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('İlanı Sil'),
          content: const Text('Bu ilanı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Sil'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDeletePressed();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return AppColors.success;
      case 'draft':
        return AppColors.textSecondary;
      case 'completed':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'published':
        return 'Yayında';
      case 'draft':
        return 'Taslak';
      case 'completed':
        return 'Tamamlandı';
      default:
        return status;
    }
  }
}