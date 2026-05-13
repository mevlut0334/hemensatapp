// lib/logic/repair_listing/create_repair_listing_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/repair_listing_repository.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'create_repair_listing_event.dart';
import 'create_repair_listing_state.dart';

class CreateRepairListingBloc extends Bloc<CreateRepairListingEvent, CreateRepairListingState> {
  final RepairListingRepository repairListingRepository;
  final AuthBloc authBloc;

  CreateRepairListingBloc({
    required this.repairListingRepository,
    required this.authBloc,
  }) : super(CreateRepairListingInitial()) {
    on<LoadCreateRepairListingData>(_onLoadData);
    on<SelectRepairBrand>(_onSelectBrand);
    on<SelectRepairModel>(_onSelectModel);
    on<AddRepairImage>(_onAddImage);
    on<RemoveRepairImage>(_onRemoveImage);
    on<UpdateRepairPhone>(_onUpdatePhone);
    on<UpdateRepairTitle>(_onUpdateTitle);
    on<UpdateRepairDescription>(_onUpdateDescription);
    on<SubmitRepairListing>(_onSubmitRepairListing);
    on<ResetCreateRepairListingForm>(_onResetForm);
  }

  // İlk verileri yükle (Sadece Marka)
  Future<void> _onLoadData(
    LoadCreateRepairListingData event,
    Emitter<CreateRepairListingState> emit,
  ) async {
    emit(CreateRepairListingLoadingData());
    
    try {
      final brands = await repairListingRepository.getBrands();

      emit(CreateRepairListingDataLoaded(
        brands: brands,
      ));
    } catch (e) {
      emit(CreateRepairListingError('Veriler yüklenirken hata oluştu: ${e.toString()}'));
    }
  }

  // Marka seçildiğinde modelleri getir
  Future<void> _onSelectBrand(
    SelectRepairBrand event,
    Emitter<CreateRepairListingState> emit,
  ) async {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    
    // Önce seçimi güncelle ve modelleri temizle
    emit(currentState.copyWith(
      selectedBrand: event.brand,
      selectedModel: null,
      models: [],
    ));

    try {
      // Seçilen markaya ait modelleri getir
      final models = await repairListingRepository.getModelsByBrand(event.brand.id);
      
      final updatedState = state as CreateRepairListingDataLoaded;
      emit(updatedState.copyWith(
        models: models,
      ));
    } catch (e) {
      emit(CreateRepairListingError('Modeller yüklenirken hata oluştu: ${e.toString()}'));
      emit(currentState.copyWith(
        selectedBrand: event.brand,
        selectedModel: null,
        models: [],
      ));
    }
  }

  // Model seçildiğinde
  void _onSelectModel(
    SelectRepairModel event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    emit(currentState.copyWith(selectedModel: event.model));
  }

  // Görsel ekle (Maksimum 3 adet)
  void _onAddImage(
    AddRepairImage event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    
    if (currentState.selectedImages.length >= 3) {
      emit(const CreateRepairListingError('Maksimum 3 görsel yükleyebilirsiniz'));
      emit(currentState);
      return;
    }

    final updatedImages = List<String>.from(currentState.selectedImages)
      ..add(event.imagePath);

    emit(currentState.copyWith(selectedImages: updatedImages));
  }

  // Görsel çıkar
  void _onRemoveImage(
    RemoveRepairImage event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    final updatedImages = List<String>.from(currentState.selectedImages)
      ..remove(event.imagePath);

    emit(currentState.copyWith(selectedImages: updatedImages));
  }

  // Telefon numarası güncelle
  void _onUpdatePhone(
    UpdateRepairPhone event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    emit(currentState.copyWith(phone: event.phone));
  }

  // Başlık güncelle
  void _onUpdateTitle(
    UpdateRepairTitle event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    emit(currentState.copyWith(title: event.title));
  }

  // Açıklama güncelle
  void _onUpdateDescription(
    UpdateRepairDescription event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    emit(currentState.copyWith(description: event.description));
  }

  // İlanı oluştur
  Future<void> _onSubmitRepairListing(
    SubmitRepairListing event,
    Emitter<CreateRepairListingState> emit,
  ) async {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;

    // Kullanıcı bilgilerini AuthBloc'tan al
    final authState = authBloc.state;
    if (authState is! AuthAuthenticated) {
      emit(const CreateRepairListingError('Kullanıcı oturumu bulunamadı'));
      emit(currentState);
      return;
    }

    final currentUser = authState.user;

    // Validasyonlar
    if (currentState.selectedBrand == null) {
      emit(const CreateRepairListingError('Lütfen marka seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedModel == null) {
      emit(const CreateRepairListingError('Lütfen model seçiniz'));
      emit(currentState);
      return;
    }
    if (currentState.phone == null || currentState.phone!.isEmpty) {
      emit(const CreateRepairListingError('Lütfen telefon numaranızı giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.title == null || currentState.title!.isEmpty) {
      emit(const CreateRepairListingError('Lütfen başlık giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.description == null || currentState.description!.isEmpty) {
      emit(const CreateRepairListingError('Lütfen açıklama giriniz'));
      emit(currentState);
      return;
    }
    if (currentState.selectedImages.isEmpty) {
      emit(const CreateRepairListingError('Lütfen en az 1 görsel ekleyiniz'));
      emit(currentState);
      return;
    }

    emit(CreateRepairListingSubmitting());

    try {
      await repairListingRepository.createRepairListing(
        brandId: currentState.selectedBrand!.id,
        modelId: currentState.selectedModel!.id,
        provinceId: currentUser.provinceId,
        districtId: currentUser.districtId,
        phone: currentState.phone!,
        title: currentState.title!,
        description: currentState.description!,
        imagePaths: currentState.selectedImages,
      );

      emit(const CreateRepairListingSuccess());
    } catch (e) {
      emit(CreateRepairListingError('İlan oluşturulurken hata oluştu: ${e.toString()}'));
      emit(currentState);
    }
  }

  // Formu sıfırla
  void _onResetForm(
    ResetCreateRepairListingForm event,
    Emitter<CreateRepairListingState> emit,
  ) {
    if (state is! CreateRepairListingDataLoaded) return;

    final currentState = state as CreateRepairListingDataLoaded;
    emit(CreateRepairListingDataLoaded(
      brands: currentState.brands,
      selectedImages: const [],
    ));
  }
}