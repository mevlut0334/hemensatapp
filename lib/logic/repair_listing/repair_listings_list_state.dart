import 'package:equatable/equatable.dart';
import '../../data/models/repair_listing_model.dart';

abstract class RepairListingsListState extends Equatable {
  const RepairListingsListState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class RepairListingsListInitial extends RepairListingsListState {
  const RepairListingsListInitial();
}

// Yüklenirken
class RepairListingsListLoading extends RepairListingsListState {
  const RepairListingsListLoading();
}

// İlanlar yüklendi
class RepairListingsListLoaded extends RepairListingsListState {
  final List<RepairListingModel> listings;

  const RepairListingsListLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

// İlan bulunamadı
class RepairListingsListEmpty extends RepairListingsListState {
  const RepairListingsListEmpty();
}

// Hata durumu
class RepairListingsListError extends RepairListingsListState {
  final String message;

  const RepairListingsListError({required this.message});

  @override
  List<Object?> get props => [message];
}