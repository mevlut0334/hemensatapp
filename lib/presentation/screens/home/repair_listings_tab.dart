// lib/presentation/screens/home/repair_listings_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/repair_listing/repair_listings_list_bloc.dart';
import '../../../logic/repair_listing/repair_listings_list_event.dart';
import '../../../logic/repair_listing/repair_listings_list_state.dart';
import 'repair_listing_card.dart';

class RepairListingsTab extends StatelessWidget {
  const RepairListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepairListingsListBloc, RepairListingsListState>(
      builder: (context, state) {
        if (state is RepairListingsListLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is RepairListingsListError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<RepairListingsListBloc>().add(const LoadRepairListings());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is RepairListingsListEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.build_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bölgenizde henüz tamir ilanı yok',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is RepairListingsListLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RepairListingsListBloc>().add(const RefreshRepairListings());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.listings.length,
              itemBuilder: (context, index) {
                final listing = state.listings[index];
                return RepairListingCard(
                  listing: listing,
                  onDetailNavigate: () => _navigateToDetail(context, listing.id),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToDetail(BuildContext context, int listingId) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('İlan detay sayfası açılacak (ID: $listingId)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}