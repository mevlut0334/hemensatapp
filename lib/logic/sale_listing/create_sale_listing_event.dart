// lib/logic/sale_listing/create_sale_listing_event.dart

import 'package:equatable/equatable.dart';
import '../../data/models/brand_model.dart';
import '../../data/models/device_model.dart';
import '../../data/models/storage_capacity_model.dart';
import '../../data/models/purchase_source_model.dart';

abstract class CreateSaleListingEvent extends Equatable {
  const CreateSaleListingEvent();

  @override
  List<Object?> get props => [];
}

// İlk yükleme - Marka, Depolama, Satın Alma Kaynağı verilerini getir
class LoadCreateSaleListingData extends CreateSaleListingEvent {}

// Marka seçildiğinde - Modelleri getir
class SelectBrand extends CreateSaleListingEvent {
  final BrandModel brand;

  const SelectBrand(this.brand);

  @override
  List<Object?> get props => [brand];
}

// Model seçildiğinde
class SelectModel extends CreateSaleListingEvent {
  final DeviceModel model;

  const SelectModel(this.model);

  @override
  List<Object?> get props => [model];
}

// Depolama kapasitesi seçildiğinde
class SelectStorage extends CreateSaleListingEvent {
  final StorageCapacityModel storage;

  const SelectStorage(this.storage);

  @override
  List<Object?> get props => [storage];
}

// Satın alma kaynağı seçildiğinde
class SelectPurchaseSource extends CreateSaleListingEvent {
  final PurchaseSourceModel purchaseSource;

  const SelectPurchaseSource(this.purchaseSource);

  @override
  List<Object?> get props => [purchaseSource];
}

// Görsel ekle
class AddImage extends CreateSaleListingEvent {
  final String imagePath;

  const AddImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Görsel çıkar
class RemoveImage extends CreateSaleListingEvent {
  final String imagePath;

  const RemoveImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Telefon numarası güncelle
class UpdatePhone extends CreateSaleListingEvent {
  final String phone;

  const UpdatePhone(this.phone);

  @override
  List<Object?> get props => [phone];
}

// Başlık güncelle
class UpdateTitle extends CreateSaleListingEvent {
  final String title;

  const UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

// Açıklama güncelle
class UpdateDescription extends CreateSaleListingEvent {
  final String description;

  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

// İlanı oluştur
class SubmitSaleListing extends CreateSaleListingEvent {}

// Formu sıfırla
class ResetCreateSaleListingForm extends CreateSaleListingEvent {}