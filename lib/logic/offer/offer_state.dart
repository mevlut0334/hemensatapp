// lib/logic/offer/offer_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/offer_model.dart';

abstract class OfferState extends Equatable {
  const OfferState();

  @override
  List<Object?> get props => [];
}

/// Başlangıç durumu
class OfferInitial extends OfferState {
  const OfferInitial();
}

/// Yükleniyor durumu
class OfferLoading extends OfferState {
  const OfferLoading();
}

/// Teklif başarıyla oluşturuldu
class OfferCreated extends OfferState {
  final OfferModel offer;
  final String message;

  const OfferCreated({
    required this.offer,
    this.message = 'Teklifiniz başarıyla gönderildi',
  });

  @override
  List<Object?> get props => [offer, message];
}

/// Gönderilen teklifler yüklendi
class MySentOffersLoaded extends OfferState {
  final List<OfferModel> offers;

  const MySentOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

/// Gelen teklifler yüklendi
class MyReceivedOffersLoaded extends OfferState {
  final List<OfferModel> offers;

  const MyReceivedOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

/// Belirli ilana ait teklifler yüklendi
class ListingOffersLoaded extends OfferState {
  final List<OfferModel> offers;
  final int listingId;
  final String listingType;

  const ListingOffersLoaded({
    required this.offers,
    required this.listingId,
    required this.listingType,
  });

  @override
  List<Object?> get props => [offers, listingId, listingType];
}

/// Teklif başarıyla kabul edildi
class OfferAccepted extends OfferState {
  final int offerId;
  final String message;

  const OfferAccepted({
    required this.offerId,
    this.message = 'Teklif başarıyla kabul edildi',
  });

  @override
  List<Object?> get props => [offerId, message];
}

/// Teklif başarıyla reddedildi
class OfferRejected extends OfferState {
  final int offerId;
  final String message;

  const OfferRejected({
    required this.offerId,
    this.message = 'Teklif reddedildi',
  });

  @override
  List<Object?> get props => [offerId, message];
}

/// Teklif başarıyla silindi
class OfferDeleted extends OfferState {
  final int offerId;
  final String message;

  const OfferDeleted({
    required this.offerId,
    this.message = 'Teklifiniz silindi',
  });

  @override
  List<Object?> get props => [offerId, message];
}

/// Hata durumu
class OfferError extends OfferState {
  final String message;

  const OfferError(this.message);

  @override
  List<Object?> get props => [message];
}

/// İşlem başarılı (genel başarı mesajı için)
class OfferActionSuccess extends OfferState {
  final String message;

  const OfferActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}