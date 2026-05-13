// lib/logic/sale_listing/sale_listings_list_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/sale_listing_model.dart';

abstract class SaleListingsListState extends Equatable {
  const SaleListingsListState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class SaleListingsListInitial extends SaleListingsListState {
  const SaleListingsListInitial();
}

// Yüklenirken
class SaleListingsListLoading extends SaleListingsListState {
  const SaleListingsListLoading();
}

// İlanlar yüklendi
class SaleListingsListLoaded extends SaleListingsListState {
  final List<SaleListingModel> listings;
  final int? filteredBrandId;
  final int? filteredModelId;
  final int? filteredProvinceId;
  final int? filteredDistrictId;
  final bool hasActiveFilters;

  const SaleListingsListLoaded({
    required this.listings,
    this.filteredBrandId,
    this.filteredModelId,
    this.filteredProvinceId,
    this.filteredDistrictId,
  }) : hasActiveFilters = filteredBrandId != null ||
            filteredModelId != null ||
            filteredProvinceId != null ||
            filteredDistrictId != null;

  @override
  List<Object?> get props => [
        listings,
        filteredBrandId,
        filteredModelId,
        filteredProvinceId,
        filteredDistrictId,
        hasActiveFilters,
      ];
}

// İlan bulunamadı
class SaleListingsListEmpty extends SaleListingsListState {
  final bool hasActiveFilters;

  const SaleListingsListEmpty({this.hasActiveFilters = false});

  @override
  List<Object?> get props => [hasActiveFilters];
}

// Hata durumu
class SaleListingsListError extends SaleListingsListState {
  final String message;

  const SaleListingsListError({required this.message});

  @override
  List<Object?> get props => [message];
}