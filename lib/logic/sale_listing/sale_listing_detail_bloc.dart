import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sale_listing_repository.dart';
import '../../data/models/sale_listing_model.dart';
import '../../core/network/api_exception.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'sale_listing_detail_event.dart';
import 'sale_listing_detail_state.dart';

class SaleListingDetailBloc extends Bloc<SaleListingDetailEvent, SaleListingDetailState> {
  final SaleListingRepository _saleListingRepository;
  final AuthBloc _authBloc;

  SaleListingDetailBloc({
    required SaleListingRepository saleListingRepository,
    required AuthBloc authBloc,
  })  : _saleListingRepository = saleListingRepository,
        _authBloc = authBloc,
        super(const SaleListingDetailInitial()) {
    on<LoadSaleListingDetail>(_onLoadSaleListingDetail);
    on<RefreshSaleListingDetail>(_onRefreshSaleListingDetail);
  }

  Future<void> _onLoadSaleListingDetail(
    LoadSaleListingDetail event,
    Emitter<SaleListingDetailState> emit,
  ) async {
    emit(const SaleListingDetailLoading());

    try {
      // Kullanıcı bilgilerini al
      bool isOwnListing = event.isOwnListing ?? false;

      // Backend'den ilan detayını çek - isOwnListing parametresini ekle
      final listing = await _saleListingRepository.getSaleListingDetail(
        event.listingId,
        isOwnListing: isOwnListing,
      );

      // Kullanıcı iletişim bilgilerini görebilir mi kontrol et
      final canViewContact = _canUserViewContact(listing);

      emit(SaleListingDetailLoaded(
        listing: listing,
        canViewContact: canViewContact,
      ));
    } on ApiException catch (e) {
      emit(SaleListingDetailError(message: e.message));
    } catch (e) {
      emit(SaleListingDetailError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSaleListingDetail(
    RefreshSaleListingDetail event,
    Emitter<SaleListingDetailState> emit,
  ) async {
    try {
      bool isOwnListing = event.isOwnListing ?? false;

      // Backend'den ilan detayını yeniden çek - isOwnListing parametresini ekle
      final listing = await _saleListingRepository.getSaleListingDetail(
        event.listingId,
        isOwnListing: isOwnListing,
      );

      // Kullanıcı iletişim bilgilerini görebilir mi kontrol et
      final canViewContact = _canUserViewContact(listing);

      emit(SaleListingDetailLoaded(
        listing: listing,
        canViewContact: canViewContact,
      ));
    } on ApiException catch (e) {
      emit(SaleListingDetailError(message: e.message));
    } catch (e) {
      emit(SaleListingDetailError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  // İletişim bilgisi görme yetkisi kontrolü
  bool _canUserViewContact(SaleListingModel listing) {
    final authState = _authBloc.state;

    // Kullanıcı giriş yapmamışsa göremez
    if (authState is! AuthAuthenticated) {
      return false;
    }

    final currentUserId = authState.user.id;

    // İlan sahibi her zaman görebilir
    if (listing.user.id == currentUserId) {
      return true;
    }

    // Abone olan kullanıcılar görebilir
    if (authState.user.isSubscribed) {
      return true;
    }

    return false;
  }
}