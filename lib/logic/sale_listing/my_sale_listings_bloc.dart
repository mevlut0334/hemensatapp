import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sale_listing_repository.dart';
import '../../core/network/api_exception.dart';
import 'my_sale_listings_event.dart';
import 'my_sale_listings_state.dart';

class MySaleListingsBloc extends Bloc<MySaleListingsEvent, MySaleListingsState> {
  final SaleListingRepository _saleListingRepository;

  MySaleListingsBloc({
    required SaleListingRepository saleListingRepository,
  })  : _saleListingRepository = saleListingRepository,
        super(const MySaleListingsInitial()) {
    on<LoadMySaleListings>(_onLoadMySaleListings);
    on<RefreshMySaleListings>(_onRefreshMySaleListings);
    on<DeleteMySaleListing>(_onDeleteMySaleListing);
  }

  Future<void> _onLoadMySaleListings(
    LoadMySaleListings event,
    Emitter<MySaleListingsState> emit,
  ) async {
    emit(const MySaleListingsLoading());

    try {
      final listings = await _saleListingRepository.getMySaleListings();

      if (listings.isEmpty) {
        emit(const MySaleListingsEmpty());
      } else {
        emit(MySaleListingsLoaded(listings: listings));
      }
    } on ApiException catch (e) {
      emit(MySaleListingsError(message: e.message));
    } catch (e) {
      emit(MySaleListingsError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshMySaleListings(
    RefreshMySaleListings event,
    Emitter<MySaleListingsState> emit,
  ) async {
    try {
      final listings = await _saleListingRepository.getMySaleListings();

      if (listings.isEmpty) {
        emit(const MySaleListingsEmpty());
      } else {
        emit(MySaleListingsLoaded(listings: listings));
      }
    } on ApiException catch (e) {
      emit(MySaleListingsError(message: e.message));
    } catch (e) {
      emit(MySaleListingsError(message: 'Bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMySaleListing(
    DeleteMySaleListing event,
    Emitter<MySaleListingsState> emit,
  ) async {
    // Mevcut state'i al
    final currentState = state;
    if (currentState is! MySaleListingsLoaded) return;

    // Silme işlemi başladığını göster
    emit(MySaleListingDeleting(
      listingId: event.listingId,
      currentListings: currentState.listings,
    ));

    try {
      await _saleListingRepository.deleteSaleListing(event.listingId);

      // Silinen ilanı listeden çıkar
      final updatedListings = currentState.listings
          .where((listing) => listing.id != event.listingId)
          .toList();

      if (updatedListings.isEmpty) {
        emit(const MySaleListingsEmpty());
      } else {
        emit(MySaleListingsLoaded(listings: updatedListings));
      }
    } on ApiException catch (e) {
      // Hata durumunda önceki listeyi geri yükle
      emit(MySaleListingsLoaded(listings: currentState.listings));
      emit(MySaleListingsError(message: e.message));
      emit(MySaleListingsLoaded(listings: currentState.listings));
    } catch (e) {
      // Hata durumunda önceki listeyi geri yükle
      emit(MySaleListingsLoaded(listings: currentState.listings));
      emit(MySaleListingsError(message: 'İlan silinemedi: ${e.toString()}'));
      emit(MySaleListingsLoaded(listings: currentState.listings));
    }
  }
}