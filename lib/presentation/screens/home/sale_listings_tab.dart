// lib/presentation/screens/home/sale_listings_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/sale_listing/sale_listings_list_bloc.dart';
import '../../../logic/sale_listing/sale_listings_list_event.dart';
import '../../../logic/sale_listing/sale_listings_list_state.dart';
import 'sale_listing_card.dart';
import 'sale_listing_filter_dialog.dart';
import '../../../core/service_locator.dart';
import '../../../logic/location/location_cubit.dart';

class SaleListingsTab extends StatelessWidget {
  const SaleListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtreleme butonu
        _buildFilterButton(context),
        
        // İlanlar listesi
        Expanded(
          child: BlocBuilder<SaleListingsListBloc, SaleListingsListState>(
            builder: (context, state) {
              if (state is SaleListingsListLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is SaleListingsListError) {
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
                          context.read<SaleListingsListBloc>().add(const LoadSaleListings());
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

              if (state is SaleListingsListEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.hasActiveFilters
                            ? 'Filtrelere uygun ilan bulunamadı'
                            : 'Bölgenizde henüz satış ilanı yok',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (state.hasActiveFilters) ...[
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            context.read<SaleListingsListBloc>().add(const ClearSaleListingsFilters());
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Filtreleri Temizle'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              if (state is SaleListingsListLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<SaleListingsListBloc>().add(const RefreshSaleListings());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.listings.length,
                    itemBuilder: (context, index) {
                      final listing = state.listings[index];
                      return SaleListingCard(
                        listing: listing,
                        onDetailNavigate: () => _navigateToDetail(context, listing.id),
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return BlocBuilder<SaleListingsListBloc, SaleListingsListState>(
      builder: (context, state) {
        final hasActiveFilters = state is SaleListingsListLoaded && state.hasActiveFilters;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showFilterDialog(context),
                  icon: Icon(
                    hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: hasActiveFilters ? AppColors.primary : AppColors.textSecondary,
                  ),
                  label: Text(
                    hasActiveFilters ? 'Filtreler Aktif' : 'Filtrele',
                    style: TextStyle(
                      color: hasActiveFilters ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: hasActiveFilters ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: hasActiveFilters ? AppColors.primary : AppColors.border,
                      width: hasActiveFilters ? 2 : 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    context.read<SaleListingsListBloc>().add(const ClearSaleListingsFilters());
                  },
                  icon: const Icon(Icons.clear),
                  color: AppColors.error,
                  tooltip: 'Filtreleri Temizle',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<SaleListingsListBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<LocationCubit>(),
        ),
      ],
      child: const SaleListingFilterDialog(),
    ),
  );
}

  void _navigateToDetail(BuildContext context, int listingId) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Satış ilanı detay sayfası açılacak (ID: $listingId)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}