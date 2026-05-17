import 'package:get_it/get_it.dart';
import 'package:hemensatapp/logic/repair_listing/repair_listings_list_bloc.dart';
import 'package:hemensatapp/logic/sale_listing/my_sale_listings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemensatapp/core/network/api_client.dart';
import 'package:hemensatapp/core/storage/local_storage.dart';
import 'package:hemensatapp/data/repositories/auth_repository.dart';
import 'package:hemensatapp/data/repositories/location_repository.dart';
import 'package:hemensatapp/data/repositories/sale_listing_repository.dart';
import 'package:hemensatapp/logic/auth/auth_bloc.dart';
import 'package:hemensatapp/logic/location/location_cubit.dart';
import 'package:hemensatapp/logic/sale_listing/create_sale_listing_bloc.dart';
import 'package:hemensatapp/data/repositories/repair_listing_repository.dart';
import 'package:hemensatapp/logic/repair_listing/create_repair_listing_bloc.dart';
import 'package:hemensatapp/data/repositories/offer_repository.dart';
import 'package:hemensatapp/logic/offer/offer_bloc.dart';
import 'package:hemensatapp/logic/sale_listing/sale_listings_list_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/my_repair_listings_bloc.dart';
import 'package:hemensatapp/core/services/fcm_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Local Storage
  sl.registerSingleton<LocalStorage>(LocalStorage(sl<SharedPreferences>()));

  // API Client
  sl.registerSingleton<ApiClient>(ApiClient(sl<LocalStorage>()));

  // Auth Repository
  sl.registerSingleton<AuthRepository>(
    AuthRepository(sl<ApiClient>(), sl<LocalStorage>()),
  );

  // Location Repository
  sl.registerSingleton<LocationRepository>(LocationRepository(sl<ApiClient>()));

  // Sale Listing Repository
  sl.registerSingleton<SaleListingRepository>(
    SaleListingRepository(sl<ApiClient>()),
  );

  // Repair Listing Repository
  sl.registerSingleton<RepairListingRepository>(
    RepairListingRepository(sl<ApiClient>()),
  );

   // Offer Repository
  sl.registerSingleton<OfferRepository>(
    OfferRepository(apiClient: sl<ApiClient>()),
  );

  // Auth BLoC - SINGLETON YAPILDI (registerFactory yerine registerLazySingleton)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      localStorage: sl<LocalStorage>(),
    ),
  );

  // Location Cubit
  sl.registerFactory<LocationCubit>(
    () => LocationCubit(sl<LocationRepository>()),
  );

  // Create Sale Listing BLoC
  sl.registerFactory<CreateSaleListingBloc>(
    () => CreateSaleListingBloc(
      saleListingRepository: sl<SaleListingRepository>(),
      authBloc: sl<AuthBloc>(),
    ),
  );

  // Create Repair Listing BLoC
  sl.registerFactory<CreateRepairListingBloc>(
    () => CreateRepairListingBloc(
      repairListingRepository: sl<RepairListingRepository>(),
      authBloc: sl<AuthBloc>(),
    ),
  );

   // Repair Listings List BLoC - YENİ EKLENEN
  sl.registerFactory<RepairListingsListBloc>(
    () => RepairListingsListBloc(
      repairListingRepository: sl<RepairListingRepository>(),
      authBloc: sl<AuthBloc>(),
    ),
  );

  // Sale Listings List BLoC
sl.registerFactory<SaleListingsListBloc>(
  () => SaleListingsListBloc(
    saleListingRepository: sl<SaleListingRepository>(),
    authBloc: sl<AuthBloc>(),
  ),
);

  // My Sale Listings BLoC - YENİ EKLENEN
  sl.registerFactory<MySaleListingsBloc>(
    () => MySaleListingsBloc(
      saleListingRepository: sl<SaleListingRepository>(),
    ),
  );

  // My Repair Listings BLoC - YENİ EKLENEN
  sl.registerFactory<MyRepairListingsBloc>(
    () => MyRepairListingsBloc(
      repairListingRepository: sl<RepairListingRepository>(),
    ),
  );
// FCM Service
  sl.registerSingleton<FcmService>(FcmService(sl<ApiClient>()));
  // Offer BLoC
  sl.registerFactory<OfferBloc>(
    () => OfferBloc(
      offerRepository: sl<OfferRepository>(),
    ),
  );
}
