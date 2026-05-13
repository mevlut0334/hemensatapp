import 'package:equatable/equatable.dart';
import 'package:hemensatapp/data/models/repair_listing_model.dart';

// Temel abstract state sınıfı
abstract class MyRepairListingsState extends Equatable {
  const MyRepairListingsState();

  @override
  List<Object> get props => [];
}

// Başlangıç durumu
class MyRepairListingsInitial extends MyRepairListingsState {}

// İlanların yüklendiği durum
class MyRepairListingsLoading extends MyRepairListingsState {}

// İlanların başarıyla yüklendiği ve listelendiği durum
class MyRepairListingsLoaded extends MyRepairListingsState {
  final List<RepairListingModel> listings;

  const MyRepairListingsLoaded(this.listings);

  @override
  List<Object> get props => [listings];
}

// Silme işleminin devam ettiğini belirten durum
// Bu durum, arayüzde hangi kartın silindiğini göstermek için kullanılır
class MyRepairListingDeleting extends MyRepairListingsState {
  final List<RepairListingModel> currentListings;
  final int listingId;

  const MyRepairListingDeleting({
    required this.currentListings,
    required this.listingId,
  });

  @override
  List<Object> get props => [currentListings, listingId];
}


// Yüklenecek hiç ilan olmadığında kullanılan durum
class MyRepairListingsEmpty extends MyRepairListingsState {}

// Hata durumu
class MyRepairListingsError extends MyRepairListingsState {
  final String message;

  const MyRepairListingsError(this.message);

  @override
  List<Object> get props => [message];
}