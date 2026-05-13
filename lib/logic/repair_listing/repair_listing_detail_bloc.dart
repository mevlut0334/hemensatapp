// lib/logic/repair_listing/repair_listing_detail_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/repair_listing_repository.dart';
import '../../data/models/repair_listing_model.dart';
import '../../core/network/api_exception.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'repair_listing_detail_event.dart';
import 'repair_listing_detail_state.dart';

class RepairListingDetailBloc extends Bloc<RepairListingDetailEvent, RepairListingDetailState> {
  final RepairListingRepository _repairListingRepository;
  final AuthBloc _authBloc;

  RepairListingDetailBloc({
    required RepairListingRepository repairListingRepository,
    required AuthBloc authBloc,
  })  : _repairListingRepository = repairListingRepository,
        _authBloc = authBloc,
        super(const RepairListingDetailInitial()) {
    on<LoadRepairListingDetail>(_onLoadRepairListingDetail);
    on<RefreshRepairListingDetail>(_onRefreshRepairListingDetail);
  }

  Future<void> _onLoadRepairListingDetail(
    LoadRepairListingDetail event,
    Emitter<RepairListingDetailState> emit,
  ) async {
    emit(const RepairListingDetailLoading());

    try {
      // Kullanıcı bilgilerini al
      final authState = _authBloc.state;
      int? currentUserId;
      bool isOwnListing = false;

      if (authState is AuthAuthenticated) {
        currentUserId = authState.user.id;
        // Event'ten gelen bilgiyi kullan (liste sayfasından gelen)
        isOwnListing = event.isOwnListing ?? false;
      }

      // Backend'den ilan detayını çek - isOwnListing parametresiyle
      final listing = await _repairListingRepository.getRepairListingDetail(
        event.listingId,
        currentUserId: currentUserId,
        isOwnListing: isOwnListing,
      );

      // Kullanıcı iletişim bilgilerini görebilir mi kontrol et
      final canViewContact = _canUserViewContact(listing);

      emit(RepairListingDetailLoaded(
        listing: listing,
        canViewContact: canViewContact,
      ));
    } on ApiException catch (e) {
      emit(RepairListingDetailError(message: e.message));
    } catch (e) {
      emit(RepairListingDetailError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRepairListingDetail(
    RefreshRepairListingDetail event,
    Emitter<RepairListingDetailState> emit,
  ) async {
    try {
      // Kullanıcı bilgilerini al
      final authState = _authBloc.state;
      int? currentUserId;
      bool isOwnListing = false;

      if (authState is AuthAuthenticated) {
        currentUserId = authState.user.id;
        isOwnListing = event.isOwnListing ?? false;
      }

      // Backend'den ilan detayını yeniden çek
      final listing = await _repairListingRepository.getRepairListingDetail(
        event.listingId,
        currentUserId: currentUserId,
        isOwnListing: isOwnListing,
      );

      // Kullanıcı iletişim bilgilerini görebilir mi kontrol et
      final canViewContact = _canUserViewContact(listing);

      emit(RepairListingDetailLoaded(
        listing: listing,
        canViewContact: canViewContact,
      ));
    } on ApiException catch (e) {
      emit(RepairListingDetailError(message: e.message));
    } catch (e) {
      emit(RepairListingDetailError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  // İletişim bilgisi görme yetkisi kontrolü
  bool _canUserViewContact(RepairListingModel listing) {
    final authState = _authBloc.state;

    // Kullanıcı giriş yapmamışsa göremez
    if (authState is! AuthAuthenticated) {
      return false;
    }

    final currentUserId = authState.user.id;

    // İlan sahibi her zaman görebilir (userId kullan, user.id değil!)
    if (listing.userId == currentUserId) {
      return true;
    }

    // Abone olan kullanıcılar görebilir
    if (authState.user.isSubscribed) {
      return true;
    }

    return false;
  }
}