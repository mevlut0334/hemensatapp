// lib/logic/sale_listing/sale_listings_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sale_listing_repository.dart';
import '../../core/network/api_exception.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../data/models/sale_listing_model.dart';
import 'sale_listings_list_event.dart';
import 'sale_listings_list_state.dart';

class SaleListingsListBloc
    extends Bloc<SaleListingsListEvent, SaleListingsListState> {
  final SaleListingRepository _saleListingRepository;
  final AuthBloc _authBloc;

  // Tüm ilanları cache'le (filtreleme için)
  List<SaleListingModel> _allListings = [];

  SaleListingsListBloc({
    required SaleListingRepository saleListingRepository,
    required AuthBloc authBloc,
  }) : _saleListingRepository = saleListingRepository,
       _authBloc = authBloc,
       super(const SaleListingsListInitial()) {
    on<LoadSaleListings>(_onLoadSaleListings);
    on<RefreshSaleListings>(_onRefreshSaleListings);
    on<FilterSaleListings>(_onFilterSaleListings);
    on<ClearSaleListingsFilters>(_onClearFilters);
  }

  Future<void> _onLoadSaleListings(
    LoadSaleListings event,
    Emitter<SaleListingsListState> emit,
  ) async {
    emit(const SaleListingsListLoading());

    try {
      final authState = _authBloc.state;

      if (authState is! AuthAuthenticated) {
        emit(
          const SaleListingsListError(message: 'Kullanıcı girişi bulunamadı'),
        );
        return;
      }

      final userProvinceId = authState.user.provinceId;
      final userDistrictId = authState.user.districtId;

      // Tüm satış ilanlarını getir
      final allListings = await _saleListingRepository.getSaleListings();

      // Cache'e al (filtreleme için)
      _allListings = allListings;

      // Sadece active (published) ve kullanıcının lokasyonundaki ilanları filtrele
      final filteredListings = allListings.where((listing) {
        return listing.status == 'active' &&
            listing.location.province.id == userProvinceId &&
            listing.location.district.id == userDistrictId;
      }).toList();

      if (filteredListings.isEmpty) {
        emit(const SaleListingsListEmpty());
      } else {
        emit(
          SaleListingsListLoaded(
            listings: filteredListings,
            filteredProvinceId: userProvinceId,
            filteredDistrictId: userDistrictId,
          ),
        );
      }
    } on ApiException catch (e) {
      emit(SaleListingsListError(message: e.message));
    } catch (e) {
      emit(SaleListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSaleListings(
    RefreshSaleListings event,
    Emitter<SaleListingsListState> emit,
  ) async {
    try {
      final authState = _authBloc.state;

      if (authState is! AuthAuthenticated) {
        emit(
          const SaleListingsListError(message: 'Kullanıcı girişi bulunamadı'),
        );
        return;
      }

      final userProvinceId = authState.user.provinceId;
      final userDistrictId = authState.user.districtId;

      // Tüm satış ilanlarını getir
      final allListings = await _saleListingRepository.getSaleListings();

      // Cache'e al
      _allListings = allListings;

      // Mevcut filtre varsa uygula, yoksa sadece lokasyon filtresi
      final currentState = state;

      List<SaleListingModel> filteredListings;

      if (currentState is SaleListingsListLoaded &&
          currentState.hasActiveFilters) {
        // Mevcut filtreleri koru
        filteredListings = _applyFilters(
          allListings,
          brandId: currentState.filteredBrandId,
          modelId: currentState.filteredModelId,
          provinceId: currentState.filteredProvinceId,
          districtId: currentState.filteredDistrictId,
        );
      } else {
        // Sadece lokasyon filtresi
        filteredListings = allListings.where((listing) {
          return listing.status == 'active' &&
              listing.location.province.id == userProvinceId &&
              listing.location.district.id == userDistrictId;
        }).toList();
      }

      if (filteredListings.isEmpty) {
        emit(
          SaleListingsListEmpty(
            hasActiveFilters:
                currentState is SaleListingsListLoaded &&
                currentState.hasActiveFilters,
          ),
        );
      } else {
        emit(
          SaleListingsListLoaded(
            listings: filteredListings,
            filteredBrandId: currentState is SaleListingsListLoaded
                ? currentState.filteredBrandId
                : null,
            filteredModelId: currentState is SaleListingsListLoaded
                ? currentState.filteredModelId
                : null,
            filteredProvinceId: currentState is SaleListingsListLoaded
                ? currentState.filteredProvinceId
                : userProvinceId,
            filteredDistrictId: currentState is SaleListingsListLoaded
                ? currentState.filteredDistrictId
                : userDistrictId,
          ),
        );
      }
    } on ApiException catch (e) {
      emit(SaleListingsListError(message: e.message));
    } catch (e) {
      emit(SaleListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onFilterSaleListings(
    FilterSaleListings event,
    Emitter<SaleListingsListState> emit,
  ) async {
    try {
      final authState = _authBloc.state;

      if (authState is! AuthAuthenticated) {
        emit(
          const SaleListingsListError(message: 'Kullanıcı girişi bulunamadı'),
        );
        return;
      }

      // Eğer cache boşsa önce yükle
      if (_allListings.isEmpty) {
        _allListings = await _saleListingRepository.getSaleListings();
      }

      // Filtreleri uygula
      final filteredListings = _applyFilters(
        _allListings,
        brandId: event.brandId,
        modelId: event.modelId,
        provinceId: event.provinceId,
        districtId: event.districtId,
      );

      if (filteredListings.isEmpty) {
        emit(const SaleListingsListEmpty(hasActiveFilters: true));
      } else {
        emit(
          SaleListingsListLoaded(
            listings: filteredListings,
            filteredBrandId: event.brandId,
            filteredModelId: event.modelId,
            filteredProvinceId: event.provinceId,
            filteredDistrictId: event.districtId,
          ),
        );
      }
    } on ApiException catch (e) {
      emit(SaleListingsListError(message: e.message));
    } catch (e) {
      emit(SaleListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onClearFilters(
    ClearSaleListingsFilters event,
    Emitter<SaleListingsListState> emit,
  ) async {
    try {
      final authState = _authBloc.state;

      if (authState is! AuthAuthenticated) {
        emit(
          const SaleListingsListError(message: 'Kullanıcı girişi bulunamadı'),
        );
        return;
      }

      final userProvinceId = authState.user.provinceId;
      final userDistrictId = authState.user.districtId;

      // Sadece lokasyon filtresine dön
      final filteredListings = _allListings.where((listing) {
        return listing.status == 'active' &&
            listing.location.province.id == userProvinceId &&
            listing.location.district.id == userDistrictId;
      }).toList();

      if (filteredListings.isEmpty) {
        emit(const SaleListingsListEmpty());
      } else {
        emit(
          SaleListingsListLoaded(
            listings: filteredListings,
            filteredProvinceId: userProvinceId,
            filteredDistrictId: userDistrictId,
          ),
        );
      }
    } catch (e) {
      emit(SaleListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  // Filtreleme helper metodu
  List<SaleListingModel> _applyFilters(
    List<SaleListingModel> listings, {
    int? brandId,
    int? modelId,
    int? provinceId,
    int? districtId,
  }) {
    return listings.where((listing) {
      // Sadece active ilanlar
      if (listing.status != 'active') return false;

      // Marka filtresi
      if (brandId != null && listing.brand.id != brandId) {
        return false;
      }

      // Model filtresi
      if (modelId != null && listing.model.id != modelId) {
        return false;
      }

      // İl filtresi
      if (provinceId != null && listing.location.province.id != provinceId) {
        return false;
      }

      // İlçe filtresi
      if (districtId != null && listing.location.district.id != districtId) {
        return false;
      }

      return true;
    }).toList();
  }
}