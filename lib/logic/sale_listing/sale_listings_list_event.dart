// lib/logic/sale_listing/sale_listings_list_event.dart

import 'package:equatable/equatable.dart';

abstract class SaleListingsListEvent extends Equatable {
  const SaleListingsListEvent();

  @override
  List<Object?> get props => [];
}

// Satış ilanlarını yükle
class LoadSaleListings extends SaleListingsListEvent {
  const LoadSaleListings();
}

// Satış ilanlarını yenile (refresh)
class RefreshSaleListings extends SaleListingsListEvent {
  const RefreshSaleListings();
}

// Filtreleme uygula
class FilterSaleListings extends SaleListingsListEvent {
  final int? brandId;
  final int? modelId;
  final int? provinceId;
  final int? districtId;

  const FilterSaleListings({
    this.brandId,
    this.modelId,
    this.provinceId,
    this.districtId,
  });

  @override
  List<Object?> get props => [brandId, modelId, provinceId, districtId];
}

// Filtreleri temizle
class ClearSaleListingsFilters extends SaleListingsListEvent {
  const ClearSaleListingsFilters();
}