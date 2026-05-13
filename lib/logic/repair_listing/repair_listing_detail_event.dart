// lib/logic/repair_listing/repair_listing_detail_event.dart

import 'package:equatable/equatable.dart';

abstract class RepairListingDetailEvent extends Equatable {
  const RepairListingDetailEvent();

  @override
  List<Object?> get props => [];
}

// İlan detayını yükle
class LoadRepairListingDetail extends RepairListingDetailEvent {
  final int listingId;
  final bool? isOwnListing;  // ← BU SATIRI EKLE

  const LoadRepairListingDetail({
    required this.listingId,
    this.isOwnListing,  // ← BU SATIRI EKLE
  });
}

// İlan detayını yenile
class RefreshRepairListingDetail extends RepairListingDetailEvent {
  final int listingId;
  final bool? isOwnListing;  // ← BU SATIRI EKLE

  const RefreshRepairListingDetail({
    required this.listingId,
    this.isOwnListing,  // ← BU SATIRI EKLE
  });
}