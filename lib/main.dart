import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/core/constants/app_theme.dart';
import 'package:renttie/core/router/app_refresh.dart';
import 'package:renttie/core/router/app_router.dart';
import 'package:renttie/core/router/app_router_effects.dart';
import 'package:renttie/firebase_options.dart';
import 'package:renttie/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AuthService.instance.initializeGoogleSignIn();
  } catch (e, stack) {
    debugPrint('Firebase init failed: $e\n$stack');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit = AuthCubit();
  late final RentalCubit _rentalCubit = RentalCubit();
  late final AppRouterRefresh _routerRefresh = AppRouterRefresh(_authCubit);
  late final AppRouterEffects _routerEffects = AppRouterEffects(
    authCubit: _authCubit,
    rentalCubit: _rentalCubit,
  );
  late final GoRouter _router = AppRouter.create(
    authCubit: _authCubit,
    refresh: _routerRefresh,
  );

  @override
  void initState() {
    super.initState();
    _routerEffects.start();
  }

  @override
  void dispose() {
    _routerEffects.dispose();
    _routerRefresh.dispose();
    _rentalCubit.close();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _rentalCubit),
      ],
      child: RepositoryProvider.value(
        value: _routerRefresh,
        child: MaterialApp.router(
          title: 'Renttie',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
