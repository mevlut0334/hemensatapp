import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/data/repositories/repair_listing_repository.dart';
import 'my_repair_listings_event.dart';
import 'my_repair_listings_state.dart';

class MyRepairListingsBloc extends Bloc<MyRepairListingsEvent, MyRepairListingsState> {
  final RepairListingRepository _repairListingRepository;

  MyRepairListingsBloc({required RepairListingRepository repairListingRepository})
      : _repairListingRepository = repairListingRepository,
        super(MyRepairListingsInitial()) {
    on<LoadMyRepairListings>(_onLoadMyRepairListings);
    on<RefreshMyRepairListings>(_onLoadMyRepairListings); // Yenileme de aynı fonksiyonu tetikler
    on<DeleteMyRepairListing>(_onDeleteMyRepairListing);
  }

  Future<void> _onLoadMyRepairListings(
    MyRepairListingsEvent event,
    Emitter<MyRepairListingsState> emit,
  ) async {
    emit(MyRepairListingsLoading());
    try {
      final listings = await _repairListingRepository.getMyRepairListings();
      if (listings.isEmpty) {
        emit(MyRepairListingsEmpty());
      } else {
        emit(MyRepairListingsLoaded(listings));
      }
    } catch (e) {
      emit(MyRepairListingsError('İlanlar yüklenirken bir hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMyRepairListing(
    DeleteMyRepairListing event,
    Emitter<MyRepairListingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is MyRepairListingsLoaded) {
      // Silme işlemi başlarken mevcut listeyi koru ve arayüzü güncelle
      emit(MyRepairListingDeleting(
        currentListings: currentState.listings,
        listingId: event.listingId,
      ));
      
      try {
        await _repairListingRepository.deleteRepairListing(event.listingId);
        // Silme işlemi başarılı olduktan sonra listeyi yeniden yükle
        add(const LoadMyRepairListings());
      } catch (e) {
        // Hata durumunda eski listeyi geri yükle ve hata mesajı göster
        emit(MyRepairListingsLoaded(currentState.listings));
        // İsteğe bağlı: Kullanıcıya bir hata mesajı göstermek için ayrı bir state de emit edilebilir.
        // Örneğin: emit(MySaleListingsError('İlan silinemedi: ${e.toString()}'));
      }
    }
  }
}