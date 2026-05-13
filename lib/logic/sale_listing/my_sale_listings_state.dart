import 'package:equatable/equatable.dart';
import '../../data/models/sale_listing_model.dart';

abstract class MySaleListingsState extends Equatable {
  const MySaleListingsState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class MySaleListingsInitial extends MySaleListingsState {
  const MySaleListingsInitial();
}

// Yüklenirken
class MySaleListingsLoading extends MySaleListingsState {
  const MySaleListingsLoading();
}

// İlanlar yüklendi
class MySaleListingsLoaded extends MySaleListingsState {
  final List<SaleListingModel> listings;

  const MySaleListingsLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

// İlan yok
class MySaleListingsEmpty extends MySaleListingsState {
  const MySaleListingsEmpty();
}

// Hata durumu
class MySaleListingsError extends MySaleListingsState {
  final String message;

  const MySaleListingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// İlan siliniyor
class MySaleListingDeleting extends MySaleListingsState {
  final int listingId;
  final List<SaleListingModel> currentListings; // Mevcut listeyi koru

  const MySaleListingDeleting({
    required this.listingId,
    required this.currentListings,
  });

  @override
  List<Object?> get props => [listingId, currentListings];
}