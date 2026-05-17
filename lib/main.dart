import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/create_repair_listing_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/repair_listings_list_bloc.dart';
import 'package:hemensatapp/logic/repair_listing/repair_listings_list_event.dart';
import 'package:hemensatapp/logic/sale_listing/create_sale_listing_bloc.dart';
import 'package:hemensatapp/presentation/screens/repair_listing/create_repair_listing_screen.dart';
import 'package:hemensatapp/presentation/screens/sale_listing/create_sale_listing_screen.dart';
import 'core/service_locator.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_event.dart';
import 'logic/auth/auth_state.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/theme/app_colors.dart';
import 'package:hemensatapp/presentation/screens/my_listings/my_sale_listings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  await sl<FcmService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'HemenSat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => MultiBlocProvider(
            // ← BU KISMI EKLEYİN
            providers: [
              BlocProvider(
                create: (context) =>
                    sl<RepairListingsListBloc>()
                      ..add(const LoadRepairListings()),
              ),
            ],
            child: const HomeScreen(),
          ),
          '/create-sale-listing': (context) => BlocProvider(
            create: (context) => sl<CreateSaleListingBloc>(),
            child: const CreateSaleListingScreen(),
          ),
          '/create-repair-listing': (context) => BlocProvider(
            create: (context) => sl<CreateRepairListingBloc>(),
            child: const CreateRepairListingScreen(),
          ),
          '/my-sale-listings': (context) => const MySaleListingsScreen(),
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Loading durumunda da splash göster
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashScreen();
            }

            // Eğer kullanıcı zaten giriş yapmışsa HomeScreen'e yönlendir
            if (state is AuthAuthenticated) {
              return MultiBlocProvider(
                // ← BlocProvider yerine MultiBlocProvider
                providers: [
                  BlocProvider(
                    create: (context) =>
                        sl<RepairListingsListBloc>()
                          ..add(const LoadRepairListings()),
                  ),
                ],
                child: const HomeScreen(),
              );
            }

            // Giriş yapılmamışsa SplashScreen göster
            if (state is AuthUnauthenticated) {
              return const SplashScreen();
            }

            // Varsayılan olarak SplashScreen
            return const SplashScreen();
          },
        ),
      ),
    );
  }
}
