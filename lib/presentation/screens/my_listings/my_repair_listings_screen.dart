// lib/presentation/screens/my_listings/my_repair_listings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/core/service_locator.dart';
import 'package:hemensatapp/core/theme/app_colors.dart';
import 'package:hemensatapp/logic/repair_listing/my_repair_listings_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/my_repair_listings_event.dart';
import 'package:hemensatapp/logic/repair_listing/my_repair_listings_state.dart';
import 'my_repair_listing_card.dart';

class MyRepairListingsScreen extends StatelessWidget {
  const MyRepairListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyRepairListingsBloc>()..add(const LoadMyRepairListings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tamir İlanlarım'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<MyRepairListingsBloc, MyRepairListingsState>(
          builder: (context, state) {
            if (state is MyRepairListingsLoading || state is MyRepairListingsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is MyRepairListingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MyRepairListingsBloc>().add(const LoadMyRepairListings());
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (state is MyRepairListingsEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build_circle_outlined, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'Henüz tamir ilanı oluşturmadınız.',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            if (state is MyRepairListingsLoaded || state is MyRepairListingDeleting) {
              final listings = (state is MyRepairListingsLoaded)
                  ? state.listings
                  : (state as MyRepairListingDeleting).currentListings;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MyRepairListingsBloc>().add(const RefreshMyRepairListings());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    final bool isDeleting =
                        state is MyRepairListingDeleting && state.listingId == listing.id;

                    return Opacity(
                      opacity: isDeleting ? 0.5 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isDeleting,
                        child: MyRepairListingCard(
                          listing: listing,
                          onDeletePressed: () {
                            context
                                .read<MyRepairListingsBloc>()
                                .add(DeleteMyRepairListing(listingId: listing.id));
                          },
                        ),
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