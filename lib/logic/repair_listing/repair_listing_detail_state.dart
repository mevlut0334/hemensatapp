// lib/logic/repair_listing/repair_listing_detail_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/repair_listing_model.dart';

abstract class RepairListingDetailState extends Equatable {
  const RepairListingDetailState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class RepairListingDetailInitial extends RepairListingDetailState {
  const RepairListingDetailInitial();
}

// Yüklenirken
class RepairListingDetailLoading extends RepairListingDetailState {
  const RepairListingDetailLoading();
}

// İlan detayı yüklendi
class RepairListingDetailLoaded extends RepairListingDetailState {
  final RepairListingModel listing;
  final bool canViewContact;

  const RepairListingDetailLoaded({
    required this.listing,
    required this.canViewContact,
  });

  @override
  List<Object?> get props => [listing, canViewContact];
}

// Hata durumu
class RepairListingDetailError extends RepairListingDetailState {
  final String message;

  const RepairListingDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}