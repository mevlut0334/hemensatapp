import 'package:get_it/get_it.dart';
import 'package:hemensatapp/data/repositories/sale_listing_repository.dart';
import 'package:hemensatapp/logic/sale_listing/sale_listing_detail_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Local Storage
  sl.registerSingleton<LocalStorage>(
    LocalStorage(sl<SharedPreferences>()),
  );

  // API Client
  sl.registerSingleton<ApiClient>(
    ApiClient(sl<LocalStorage>()),
  );

  // Auth Repository (2 parametre alıyor)
  sl.registerSingleton<AuthRepository>(
    AuthRepository(
      sl<ApiClient>(),
      sl<LocalStorage>(),  // ← 2. parametre eklendi
    ),
  );

   // ✅ Sale Listing Repository eklendi
  sl.registerSingleton<SaleListingRepository>(
    SaleListingRepository(sl<ApiClient>()),
  );

  // Auth BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      localStorage: sl<LocalStorage>(),
    ),
  );

  // ✅ Sale Listing Detail BLoC eklendi
  sl.registerFactory<SaleListingDetailBloc>(
    () => SaleListingDetailBloc(
      saleListingRepository: sl<SaleListingRepository>(),
      authBloc: sl<AuthBloc>(),
    ),
  );
}