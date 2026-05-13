// lib/logic/sale_listing/create_sale_listing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sale_listing_repository.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import 'create_sale_listing_event.dart';
import 'create_sale_listing_state.dart';

class CreateSaleListingBloc extends Bloc<CreateSaleListingEvent, CreateSaleListingState> {
  final SaleListingRepository saleListingRepository;
  final AuthBloc authBloc;

  CreateSaleListingBloc({
    required this.saleListingRepository,
    required this.authBloc,
  }) : super(CreateSaleListingInitial()) {
    on<LoadCreateSaleListingData>(_onLoadData);
    on<SelectBrand>(_onSelectBrand);
    on<SelectModel>(_onSelectModel);
    on<SelectStorage>(_onSelectStorage);
    on<SelectPurchaseSource>(_onSelectPurchaseSource);
    on<AddImage>(_onAddImage);
    on<RemoveImage>(_onRemoveImage);
    on<UpdatePhone>(_onUpdatePhone);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<SubmitSaleListing>(_onSubmitSaleListing);
    on<ResetCreateSaleListingForm>(_onResetForm);
  }

  // İlk verileri yükle (Marka, Depolama, Satın Alma Kaynağı)
  Future<void> _onLoadData(
    LoadCreateSaleListingData event,
    Emitter<CreateSaleListingState> emit,
  ) async {
    emit(CreateSaleListingLoadingData());
    
    try {
      // Sırayla verileri çek
      final brands = await saleListingRepository.getBrands();
      final storageCapacities = await saleListingRepository.getStorageCapacities();
      final purchaseSources = await saleListingRepository.getPurchaseSources();

      emit(CreateSaleListingDataLoaded(
        brands: brands,
        storageCapacities: storageCapacities,
        purchaseSources: purchaseSources,
      ));
    } catch (e) {
      emit(CreateSaleListingError('Veriler yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  // Marka seçildiğinde modelleri getir
  Future<void> _onSelectBrand(
    SelectBrand event,
    Emitter<CreateSaleListingState> emit,
  ) async {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    
    // Önce seçimi güncelle ve modelleri temizle
    emit(currentState.copyWith(
      selectedBrand: event.brand,
      selectedModel: null,
      models: [],
    ));

    try {
      // Seçilen markaya ait modelleri getir
      final models = await saleListingRepository.getModelsByBrand(event.brand.id);
      
      final updatedState = state as CreateSaleListingDataLoaded;
      emit(updatedState.copyWith(
        models: models,
      ));
    } catch (e) {
      emit(CreateSaleListingError('Modeller yüklenirken hata oluştu: ${e.toString()}'));
      emit(currentState.copyWith(
        selectedBrand: event.brand,
        selectedModel: null,
        models: [],
      ));
    }
  }

  // Model seçildiğinde
  void _onSelectModel(
    SelectModel event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(selectedModel: event.model));
  }

  // Depolama kapasitesi seçildiğinde
  void _onSelectStorage(
    SelectStorage event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(selectedStorage: event.storage));
  }

  // Satın alma kaynağı seçildiğinde
  void _onSelectPurchaseSource(
    SelectPurchaseSource event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(selectedPurchaseSource: event.purchaseSource));
  }

  // Görsel ekle (Maksimum 3 adet)
  void _onAddImage(
    AddImage event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    
    if (currentState.selectedImages.length >= 3) {
      emit(const CreateSaleListingError('Maksimum 3 görsel yükleyebilirsiniz'));
      emit(currentState);
      return;
    }

    final updatedImages = List<String>.from(currentState.selectedImages)
      ..add(event.imagePath);

    emit(currentState.copyWith(selectedImages: updatedImages));
  }

  // Görsel çıkar
  void _onRemoveImage(
    RemoveImage event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    final updatedImages = List<String>.from(currentState.selectedImages)
      ..remove(event.imagePath);

    emit(currentState.copyWith(selectedImages: updatedImages));
  }

  // Telefon numarası güncelle
  void _onUpdatePhone(
    UpdatePhone event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(phone: event.phone));
  }

  // Başlık güncelle
  void _onUpdateTitle(
    UpdateTitle event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(title: event.title));
  }

  // Açıklama güncelle
  void _onUpdateDescription(
    UpdateDescription event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(currentState.copyWith(description: event.description));
  }

  // İlanı oluştur
  Future<void> _onSubmitSaleListing(
    SubmitSaleListing event,
    Emitter<CreateSaleListingState> emit,
  ) async {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;

    // Kullanıcı bilgilerini AuthBloc'tan al
    final authState = authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const CreateSaleListingError('Kullanıcı oturumu bulunamadı'));
      emit(currentState);
      return;
    }

    final currentUser = authState.user;

    // Validasyonlar
    if (currentState.selectedBrand == null) {
      emit(const CreateSaleListingError('Lütfen marka seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedModel == null) {
      emit(const CreateSaleListingError('Lütfen model seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedStorage == null) {
      emit(const CreateSaleListingError('Lütfen depolama kapasitesi seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedPurchaseSource == null) {
      emit(const CreateSaleListingError('Lütfen cihazın nereden alındığını seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.phone == null || currentState.phone!.isEmpty) {
      emit(const CreateSaleListingError('Lütfen telefon numaranızı giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.title == null || currentState.title!.isEmpty) {
      emit(const CreateSaleListingError('Lütfen başlık giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.description == null || currentState.description!.isEmpty) {
      emit(const CreateSaleListingError('Lütfen açıklama giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedImages.isEmpty) {
      emit(const CreateSaleListingError('Lütfen en az 1 görsel ekleyiniz'));
      emit(currentState);
      return;
    }

    emit(CreateSaleListingSubmitting());

    try {
      await saleListingRepository.createSaleListing(
        brandId: currentState.selectedBrand!.id,
        modelId: currentState.selectedModel!.id,
        storageCapacityId: currentState.selectedStorage!.id,
        purchaseSourceId: currentState.selectedPurchaseSource!.id,
        provinceId: currentUser.provinceId,
        districtId: currentUser.districtId,
        phone: currentState.phone!,
        title: currentState.title!,
        description: currentState.description!,
        imagePaths: currentState.selectedImages,
      );

      // Job kullandığınız için listing null dönebilir, sadece success emit edelim
      emit(const CreateSaleListingSuccess());
    } catch (e) {
      emit(CreateSaleListingError('İlan oluşturulurken hata oluştu: ${e.toString()}'));
      emit(currentState);
    }
  }

  // Formu sıfırla
  void _onResetForm(
    ResetCreateSaleListingForm event,
    Emitter<CreateSaleListingState> emit,
  ) {
    if (state is! CreateSaleListingDataLoaded) return;

    final currentState = state as CreateSaleListingDataLoaded;
    emit(CreateSaleListingDataLoaded(
      brands: currentState.brands,
      storageCapacities: currentState.storageCapacities,
      purchaseSources: currentState.purchaseSources,
      selectedImages: const [],
    ));
  }
}