import 'package:bloc/bloc.dart';
import 'location_state.dart';
import '../../data/repositories/location_repository.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository _repository;

  LocationCubit(this._repository) : super(const LocationState());

  Future<void> fetchProvinces() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final provinces = await _repository.getProvinces();
      emit(state.copyWith(provinces: provinces, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> fetchDistricts(int provinceId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final districts = await _repository.getDistricts(provinceId);
      emit(state.copyWith(districts: districts, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
