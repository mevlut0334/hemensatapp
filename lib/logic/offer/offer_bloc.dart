// lib/logic/offer/offer_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/offer_repository.dart';
import 'offer_event.dart';
import 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final OfferRepository _offerRepository;

  OfferBloc({
    required OfferRepository offerRepository,
  })  : _offerRepository = offerRepository,
        super(const OfferInitial()) {
    on<CreateOfferEvent>(_onCreateOffer);
    on<LoadMySentOffersEvent>(_onLoadMySentOffers);
    on<LoadMyReceivedOffersEvent>(_onLoadMyReceivedOffers);
    on<LoadOffersForListingEvent>(_onLoadOffersForListing);
    on<AcceptOfferEvent>(_onAcceptOffer);
    on<RejectOfferEvent>(_onRejectOffer);
    on<DeleteOfferEvent>(_onDeleteOffer);
    on<ResetOfferStateEvent>(_onResetState);
  }

  /// Yeni teklif oluştur
  Future<void> _onCreateOffer(
    CreateOfferEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offer = await _offerRepository.createOffer(event.request);
      emit(OfferCreated(
        offer: offer,
        message: 'Teklifiniz başarıyla gönderildi',
      ));
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Gönderilen teklifleri yükle
  Future<void> _onLoadMySentOffers(
    LoadMySentOffersEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offers = await _offerRepository.getMySentOffers();
      emit(MySentOffersLoaded(offers));
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Gelen teklifleri yükle
  Future<void> _onLoadMyReceivedOffers(
    LoadMyReceivedOffersEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offers = await _offerRepository.getMyReceivedOffers();
      emit(MyReceivedOffersLoaded(offers));
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Belirli ilana ait teklifleri yükle
  Future<void> _onLoadOffersForListing(
    LoadOffersForListingEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final offers = await _offerRepository.getOffersForListing(
        listingId: event.listingId,
        listingType: event.listingType,
      );
      emit(ListingOffersLoaded(
        offers: offers,
        listingId: event.listingId,
        listingType: event.listingType,
      ));
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Teklifi kabul et
  Future<void> _onAcceptOffer(
    AcceptOfferEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final success = await _offerRepository.acceptOffer(event.offerId);
      if (success) {
        emit(OfferAccepted(
          offerId: event.offerId,
          message: 'Teklif başarıyla kabul edildi',
        ));
      } else {
        emit(const OfferError('Teklif kabul edilemedi'));
      }
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Teklifi reddet
  Future<void> _onRejectOffer(
    RejectOfferEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final success = await _offerRepository.rejectOffer(event.offerId);
      if (success) {
        emit(OfferRejected(
          offerId: event.offerId,
          message: 'Teklif reddedildi',
        ));
      } else {
        emit(const OfferError('Teklif reddedilemedi'));
      }
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// Teklifi sil
  Future<void> _onDeleteOffer(
    DeleteOfferEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferLoading());
    try {
      final success = await _offerRepository.deleteOffer(event.offerId);
      if (success) {
        emit(OfferDeleted(
          offerId: event.offerId,
          message: 'Teklifiniz silindi',
        ));
      } else {
        emit(const OfferError('Teklif silinemedi'));
      }
    } catch (e) {
      emit(OfferError(_extractErrorMessage(e)));
    }
  }

  /// State'i sıfırla
  Future<void> _onResetState(
    ResetOfferStateEvent event,
    Emitter<OfferState> emit,
  ) async {
    emit(const OfferInitial());
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('Exception:')) {
      return error.toString().replaceAll('Exception:', '').trim();
    }
    return error.toString();
  }
}