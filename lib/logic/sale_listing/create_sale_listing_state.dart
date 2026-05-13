import 'package:equatable/equatable.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/device_model.dart';
import '../../data/models/storage_capacity_model.dart';
import '../../data/models/purchase_source_model.dart';

abstract class CreateSaleListingState extends Equatable {
  const CreateSaleListingState();

  @override
  List<Object?> get props => [];
}

// Initial State
class CreateSaleListingInitial extends CreateSaleListingState {}

// Loading States
class CreateSaleListingLoadingData extends CreateSaleListingState {}

class CreateSaleListingSubmitting extends CreateSaleListingState {}

// Data Loaded State
class CreateSaleListingDataLoaded extends CreateSaleListingState {
  final List<BrandModel> brands;
  final List<StorageCapacityModel> storageCapacities;
  final List<PurchaseSourceModel> purchaseSources;
  final List<DeviceModel>? models; // Marka seçildiğinde dolar
  
  // Seçili değerler
  final BrandModel? selectedBrand;
  final DeviceModel? selectedModel;
  final StorageCapacityModel? selectedStorage;
  final PurchaseSourceModel? selectedPurchaseSource;
  final List<String> selectedImages;
  final String? phone;
  final String? title;
  final String? description;

  const CreateSaleListingDataLoaded({
    required this.brands,
    required this.storageCapacities,
    required this.purchaseSources,
    this.models,
    this.selectedBrand,
    this.selectedModel,
    this.selectedStorage,
    this.selectedPurchaseSource,
    this.selectedImages = const [],
    this.phone,
    this.title,
    this.description,
  });

  CreateSaleListingDataLoaded copyWith({
    List<BrandModel>? brands,
    List<StorageCapacityModel>? storageCapacities,
    List<PurchaseSourceModel>? purchaseSources,
    List<DeviceModel>? models,
    BrandModel? selectedBrand,
    DeviceModel? selectedModel,
    StorageCapacityModel? selectedStorage,
    PurchaseSourceModel? selectedPurchaseSource,
    List<String>? selectedImages,
    String? phone,
    String? title,
    String? description,
  }) {
    return CreateSaleListingDataLoaded(
      brands: brands ?? this.brands,
      storageCapacities: storageCapacities ?? this.storageCapacities,
      purchaseSources: purchaseSources ?? this.purchaseSources,
      models: models ?? this.models,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedStorage: selectedStorage ?? this.selectedStorage,
      selectedPurchaseSource: selectedPurchaseSource ?? this.selectedPurchaseSource,
      selectedImages: selectedImages ?? this.selectedImages,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        brands,
        storageCapacities,
        purchaseSources,
        models,
        selectedBrand,
        selectedModel,
        selectedStorage,
        selectedPurchaseSource,
        selectedImages,
        phone,
        title,
        description,
      ];
}

// Success State - Job kullandığınız için listing parametresi opsiyonel
class CreateSaleListingSuccess extends CreateSaleListingState {
  const CreateSaleListingSuccess();

  @override
  List<Object?> get props => [];
}

// Error State
class CreateSaleListingError extends CreateSaleListingState {
  final String message;

  const CreateSaleListingError(this.message);

  @override
  List<Object?> get props => [message];
}