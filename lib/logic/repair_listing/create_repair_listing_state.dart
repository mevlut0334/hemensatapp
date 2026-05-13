// lib/logic/repair_listing/create_repair_listing_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/device_model.dart';

abstract class CreateRepairListingState extends Equatable {
  const CreateRepairListingState();

  @override
  List<Object?> get props => [];
}

// Initial State
class CreateRepairListingInitial extends CreateRepairListingState {}

// Loading States
class CreateRepairListingLoadingData extends CreateRepairListingState {}

class CreateRepairListingSubmitting extends CreateRepairListingState {}

// Data Loaded State
class CreateRepairListingDataLoaded extends CreateRepairListingState {
  final List<BrandModel> brands;
  final List<DeviceModel>? models; // Marka seçildiğinde dolar
  
  // Seçili değerler
  final BrandModel? selectedBrand;
  final DeviceModel? selectedModel;
  final List<String> selectedImages;
  final String? phone;
  final String? title;
  final String? description;

  const CreateRepairListingDataLoaded({
    required this.brands,
    this.models,
    this.selectedBrand,
    this.selectedModel,
    this.selectedImages = const [],
    this.phone,
    this.title,
    this.description,
  });

  CreateRepairListingDataLoaded copyWith({
    List<BrandModel>? brands,
    List<DeviceModel>? models,
    BrandModel? selectedBrand,
    DeviceModel? selectedModel,
    List<String>? selectedImages,
    String? phone,
    String? title,
    String? description,
  }) {
    return CreateRepairListingDataLoaded(
      brands: brands ?? this.brands,
      models: models ?? this.models,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedImages: selectedImages ?? this.selectedImages,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        brands,
        models,
        selectedBrand,
        selectedModel,
        selectedImages,
        phone,
        title,
        description,
      ];
}

// Success State
class CreateRepairListingSuccess extends CreateRepairListingState {
  const CreateRepairListingSuccess();

  @override
  List<Object?> get props => [];
}

// Error State
class CreateRepairListingError extends CreateRepairListingState {
  final String message;

  const CreateRepairListingError(this.message);

  @override
  List<Object?> get props => [message];
}