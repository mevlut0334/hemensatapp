// lib/logic/repair_listing/create_repair_listing_event.dart

import 'package:equatable/equatable.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/device_model.dart';

abstract class CreateRepairListingEvent extends Equatable {
  const CreateRepairListingEvent();

  @override
  List<Object?> get props => [];
}

// İlk yükleme - Marka verilerini getir
class LoadCreateRepairListingData extends CreateRepairListingEvent {}

// Marka seçildiğinde - Modelleri getir
class SelectRepairBrand extends CreateRepairListingEvent {
  final BrandModel brand;

  const SelectRepairBrand(this.brand);

  @override
  List<Object?> get props => [brand];
}

// Model seçildiğinde
class SelectRepairModel extends CreateRepairListingEvent {
  final DeviceModel model;

  const SelectRepairModel(this.model);

  @override
  List<Object?> get props => [model];
}

// Görsel ekle
class AddRepairImage extends CreateRepairListingEvent {
  final String imagePath;

  const AddRepairImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Görsel çıkar
class RemoveRepairImage extends CreateRepairListingEvent {
  final String imagePath;

  const RemoveRepairImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Telefon numarası güncelle
class UpdateRepairPhone extends CreateRepairListingEvent {
  final String phone;

  const UpdateRepairPhone(this.phone);

  @override
  List<Object?> get props => [phone];
}

// Başlık güncelle
class UpdateRepairTitle extends CreateRepairListingEvent {
  final String title;

  const UpdateRepairTitle(this.title);

  @override
  List<Object?> get props => [title];
}

// Açıklama güncelle
class UpdateRepairDescription extends CreateRepairListingEvent {
  final String description;

  const UpdateRepairDescription(this.description);

  @override
  List<Object?> get props => [description];
}

// İlanı oluştur
class SubmitRepairListing extends CreateRepairListingEvent {}

// Formu sıfırla
class ResetCreateRepairListingForm extends CreateRepairListingEvent {}