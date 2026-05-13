import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/repair_listing_repository.dart';
import '../../core/network/api_exception.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import 'repair_listings_list_event.dart';
import 'repair_listings_list_state.dart';

class RepairListingsListBloc extends Bloc<RepairListingsListEvent, RepairListingsListState> {
  final RepairListingRepository _repairListingRepository;
  final AuthBloc _authBloc;

  RepairListingsListBloc({
    required RepairListingRepository repairListingRepository,
    required AuthBloc authBloc,
  })  : _repairListingRepository = repairListingRepository,
        _authBloc = authBloc,
        super(const RepairListingsListInitial()) {
    on<LoadRepairListings>(_onLoadRepairListings);
    on<RefreshRepairListings>(_onRefreshRepairListings);
  }

  Future<void> _onLoadRepairListings(
    LoadRepairListings event,
    Emitter<RepairListingsListState> emit,
  ) async {
    emit(const RepairListingsListLoading());

    try {
      // Kullanıcının lokasyon bilgisini al
      final authState = _authBloc.state;
      
      if (authState is! AuthAuthenticated) {
        emit(const RepairListingsListError(message: 'Kullanıcı girişi bulunamadı'));
        return;
      }

      final userProvinceId = authState.user.provinceId;
      final userDistrictId = authState.user.districtId;

      // Tüm tamir ilanlarını getir
      final allListings = await _repairListingRepository.getRepairListings();

      // Kullanıcının il ve ilçesine göre filtrele
      final filteredListings = allListings.where((listing) {
        return listing.location.province.id == userProvinceId &&
               listing.location.district.id == userDistrictId;
      }).toList();

      if (filteredListings.isEmpty) {
        emit(const RepairListingsListEmpty());
      } else {
        emit(RepairListingsListLoaded(listings: filteredListings));
      }
    } on ApiException catch (e) {
      emit(RepairListingsListError(message: e.message));
    } catch (e) {
      emit(RepairListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRepairListings(
    RefreshRepairListings event,
    Emitter<RepairListingsListState> emit,
  ) async {
    try {
      // Kullanıcının lokasyon bilgisini al
      final authState = _authBloc.state;
      
      if (authState is! AuthAuthenticated) {
        emit(const RepairListingsListError(message: 'Kullanıcı girişi bulunamadı'));
        return;
      }

      final userProvinceId = authState.user.provinceId;
      final userDistrictId = authState.user.districtId;

      // Tüm tamir ilanlarını getir
      final allListings = await _repairListingRepository.getRepairListings();

      // Kullanıcının il ve ilçesine göre filtrele
      final filteredListings = allListings.where((listing) {
        return listing.location.province.id == userProvinceId &&
               listing.location.district.id == userDistrictId;
      }).toList();

      if (filteredListings.isEmpty) {
        emit(const RepairListingsListEmpty());
      } else {
        emit(RepairListingsListLoaded(listings: filteredListings));
      }
    } on ApiException catch (e) {
      emit(RepairListingsListError(message: e.message));
    } catch (e) {
      emit(RepairListingsListError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }
}