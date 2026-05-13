import 'package:equatable/equatable.dart';
import '../../data/models/province_model.dart';
import '../../data/models/district_model.dart';

class LocationState extends Equatable {
  final List<ProvinceModel> provinces;
  final List<DistrictModel> districts;
  final bool isLoading;
  final String? errorMessage;

  const LocationState({
    this.provinces = const [],
    this.districts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    List<ProvinceModel>? provinces,
    List<DistrictModel>? districts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      provinces: provinces ?? this.provinces,
      districts: districts ?? this.districts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [provinces, districts, isLoading, errorMessage];
}
