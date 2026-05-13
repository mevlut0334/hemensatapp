import 'package:equatable/equatable.dart';
import '../../data/models/sale_listing_model.dart';

abstract class SaleListingDetailState extends Equatable {
  const SaleListingDetailState();
  
  @override
  List<Object?> get props => [];
}

class SaleListingDetailInitial extends SaleListingDetailState {
  const SaleListingDetailInitial();
}

class SaleListingDetailLoading extends SaleListingDetailState {
  const SaleListingDetailLoading();
}

class SaleListingDetailLoaded extends SaleListingDetailState {
  final SaleListingModel listing;
  final bool canViewContact;
  
  const SaleListingDetailLoaded({
    required this.listing,
    required this.canViewContact,
  });
  
  @override
  List<Object?> get props => [listing, canViewContact];
}

class SaleListingDetailError extends SaleListingDetailState {
  final String message;
  
  const SaleListingDetailError({required this.message});
  
  @override
  List<Object?> get props => [message];
}