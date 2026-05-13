// lib/logic/offer/offer_event.dart

import 'package:equatable/equatable.dart';
import '../../data/models/offer_model.dart';

abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object?> get props => [];
}

/// Yeni teklif oluşturma eventi
class CreateOfferEvent extends OfferEvent {
  final CreateOfferRequest request;

  const CreateOfferEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Kullanıcının gönderdiği teklifleri getir
class LoadMySentOffersEvent extends OfferEvent {
  const LoadMySentOffersEvent();
}

/// Kullanıcının ilanlarına gelen teklifleri getir
class LoadMyReceivedOffersEvent extends OfferEvent {
  const LoadMyReceivedOffersEvent();
}

/// Belirli bir ilana ait teklifleri getir
class LoadOffersForListingEvent extends OfferEvent {
  final int listingId;
  final String listingType; // 'repair' veya 'sale'

  const LoadOffersForListingEvent({
    required this.listingId,
    required this.listingType,
  });

  @override
  List<Object?> get props => [listingId, listingType];
}

/// Teklifi kabul et
class AcceptOfferEvent extends OfferEvent {
  final int offerId;

  const AcceptOfferEvent(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Teklifi reddet
class RejectOfferEvent extends OfferEvent {
  final int offerId;

  const RejectOfferEvent(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// Teklifi sil
class DeleteOfferEvent extends OfferEvent {
  final int offerId;

  const DeleteOfferEvent(this.offerId);

  @override
  List<Object?> get props => [offerId];
}

/// BLoC state'ini sıfırla
class ResetOfferStateEvent extends OfferEvent {
  const ResetOfferStateEvent();
}