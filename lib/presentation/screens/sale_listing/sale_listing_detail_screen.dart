// lib/presentation/screens/sale_listing/sale_listing_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/sale_listing/sale_listing_detail_bloc.dart';
import '../../../logic/sale_listing/sale_listing_detail_event.dart';
import '../../../logic/sale_listing/sale_listing_detail_state.dart';
import 'widgets/sale_detail_image_carousel.dart';
import 'widgets/sale_detail_info_section.dart';
import 'widgets/sale_detail_contact_section.dart';

class SaleListingDetailScreen extends StatelessWidget {
  final int listingId;
  final bool? isOwnListing;

  const SaleListingDetailScreen({
    super.key,
    required this.listingId,
    this.isOwnListing,
  });

  @override
  Widget build(BuildContext context) {
    context.read<SaleListingDetailBloc>().add(
      LoadSaleListingDetail(listingId: listingId, isOwnListing: isOwnListing),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('İlan Detayı'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Paylaşım fonksiyonu
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Favorilere ekleme
            },
          ),
        ],
      ),
      body: BlocBuilder<SaleListingDetailBloc, SaleListingDetailState>(
        builder: (context, state) {
          if (state is SaleListingDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is SaleListingDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<SaleListingDetailBloc>().add(
                          RefreshSaleListingDetail(
                            listingId: listingId,
                            isOwnListing: isOwnListing,
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
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
              ),
            );
          }

          if (state is SaleListingDetailLoaded) {
            final listing = state.listing;
            final canViewContact = state.canViewContact;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SaleListingDetailBloc>().add(
                  RefreshSaleListingDetail(
                    listingId: listingId,
                    isOwnListing: isOwnListing,
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Görsel Carousel
                    SaleDetailImageCarousel(
                      imageUrls:
                          listing.images
                              ?.map((img) => ApiConstants.getImageUrl(img.path))
                              .toList() ??
                          [],
                    ),

                    // İçerik
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Marka, Model, Depolama, Nereden Alındı, Başlık, Açıklama
                          SaleDetailInfoSection(
                            brand: listing.brand.name,
                            model: listing.model.name,
                            title: listing.title,
                            description: listing.description,
                            // condition: condition, // ← kaldırıldı
                            storage: listing.storage.capacity,
                            purchaseSource: listing.purchaseSource?.name,
                          ),
                          const SizedBox(height: 16),

                          // İletişim Bilgileri
                          SaleDetailContactSection(
                            phoneNumber: listing.phone ?? 'Belirtilmemiş',
                            canViewContact: canViewContact,
                            onSubscribePressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Premium üyelik sayfası açılacak',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
