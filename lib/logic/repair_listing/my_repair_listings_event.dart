import 'package:equatable/equatable.dart';

// Temel abstract event sınıfı
abstract class MyRepairListingsEvent extends Equatable {
  const MyRepairListingsEvent();

  @override
  List<Object> get props => [];
}

// Sayfa ilk açıldığında ilanları yüklemek için kullanılan event
class LoadMyRepairListings extends MyRepairListingsEvent {
  const LoadMyRepairListings();
}

// Sayfayı yenilemek için kullanılan event (pull-to-refresh)
class RefreshMyRepairListings extends MyRepairListingsEvent {
  const RefreshMyRepairListings();
}

// Belirli bir ilanı silmek için kullanılan event
class DeleteMyRepairListing extends MyRepairListingsEvent {
  final int listingId;

  const DeleteMyRepairListing({required this.listingId});

  @override
  List<Object> get props => [listingId];
}