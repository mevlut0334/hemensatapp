import 'package:equatable/equatable.dart';

abstract class MySaleListingsEvent extends Equatable {
  const MySaleListingsEvent();

  @override
  List<Object?> get props => [];
}

// Kullanıcının ilanlarını yükle
class LoadMySaleListings extends MySaleListingsEvent {
  const LoadMySaleListings();
}

// Kullanıcının ilanlarını yenile
class RefreshMySaleListings extends MySaleListingsEvent {
  const RefreshMySaleListings();
}

// İlanı sil
class DeleteMySaleListing extends MySaleListingsEvent {
  final int listingId;

  const DeleteMySaleListing({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}