import 'package:equatable/equatable.dart';

abstract class RepairListingsListEvent extends Equatable {
  const RepairListingsListEvent();

  @override
  List<Object?> get props => [];
}

// Tamir ilanlarını yükle
class LoadRepairListings extends RepairListingsListEvent {
  const LoadRepairListings();
}

// Tamir ilanlarını yenile (refresh)
class RefreshRepairListings extends RepairListingsListEvent {
  const RefreshRepairListings();
}