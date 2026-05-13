import 'package:equatable/equatable.dart';

abstract class SaleListingDetailEvent extends Equatable {
  const SaleListingDetailEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadSaleListingDetail extends SaleListingDetailEvent {
  final int listingId;
  final bool? isOwnListing;
  
  const LoadSaleListingDetail({
    required this.listingId,
    this.isOwnListing,
  });
  
  @override
  List<Object?> get props => [listingId, isOwnListing];
}

class RefreshSaleListingDetail extends SaleListingDetailEvent {
  final int listingId;
  final bool? isOwnListing;
  
  const RefreshSaleListingDetail({
    required this.listingId,
    this.isOwnListing,
  });
  
  @override
  List<Object?> get props => [listingId, isOwnListing];
}