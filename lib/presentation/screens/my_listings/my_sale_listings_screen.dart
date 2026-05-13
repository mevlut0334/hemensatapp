import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../logic/sale_listing/my_sale_listings_bloc.dart';
import '../../../logic/sale_listing/my_sale_listings_event.dart';
import '../../../logic/sale_listing/my_sale_listings_state.dart';
import 'my_sale_listing_card.dart';

class MySaleListingsScreen extends StatelessWidget {
  const MySaleListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MySaleListingsBloc>()..add(const LoadMySaleListings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Satış İlanlarım'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<MySaleListingsBloc, MySaleListingsState>(
          listener: (context, state) {
            if (state is MySaleListingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MySaleListingsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is MySaleListingsError) {
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
                        context.read<MySaleListingsBloc>().add(const LoadMySaleListings());
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

            if (state is MySaleListingsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sell_outlined,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz satış ilanınız yok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'İlk ilanınızı oluşturarak başlayın',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-sale-listing');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('İlan Oluştur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is MySaleListingsLoaded || state is MySaleListingDeleting) {
              final listings = state is MySaleListingsLoaded
                  ? state.listings
                  : (state as MySaleListingDeleting).currentListings;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MySaleListingsBloc>().add(const RefreshMySaleListings());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    
                    // Silme işlemi devam ediyorsa opacity ile göster
                    final isDeleting = state is MySaleListingDeleting && 
                                      state.listingId == listing.id;

                    return Opacity(
                      opacity: isDeleting ? 0.5 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isDeleting,
                        child: MySaleListingCard(listing: listing),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}