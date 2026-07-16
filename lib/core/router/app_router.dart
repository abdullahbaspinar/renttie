import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:renttie/bloc/auth/auth_cubit.dart';
import 'package:renttie/bloc/rental/rental_cubit.dart';
import 'package:renttie/core/router/app_refresh.dart';
import 'package:renttie/core/router/app_routes.dart';
import 'package:renttie/model/property.dart';
import 'package:renttie/model/tenant.dart';
import 'package:renttie/view/auth/forgot_password_page.dart';
import 'package:renttie/view/auth/login_page.dart';
import 'package:renttie/view/auth/register_page.dart';
import 'package:renttie/view/auth_choice/auth_choice.dart';
import 'package:renttie/view/home/forms/add_payment_page.dart';
import 'package:renttie/view/home/forms/add_property_page.dart';
import 'package:renttie/view/home/forms/add_tenant_page.dart';
import 'package:renttie/view/home/main_shell.dart';
import 'package:renttie/view/home/notifications_page.dart';
import 'package:renttie/view/home/profile_page.dart';
import 'package:renttie/view/home/property_detail_page.dart';
import 'package:renttie/view/home/tenant_detail_page.dart';
import 'package:renttie/view/home/tenant_payment_history_page.dart';
import 'package:renttie/view/splash/on_boarding.dart';
import 'package:renttie/view/splash/splash_screen.dart';

/// Uygulama [GoRouter] yapılandırması.
abstract final class AppRouter {
  static GoRouter create({
    required AuthCubit authCubit,
    required AppRouterRefresh refresh,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refresh,
      debugLogDiagnostics: false,
      redirect: (context, state) => _redirect(
        authCubit: authCubit,
        refresh: refresh,
        location: state.matchedLocation,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.authChoice,
          builder: (context, state) => const AuthChoicePage(),
          routes: [
            GoRoute(
              path: 'login',
              builder: (context, state) => const LoginPage(),
            ),
            GoRoute(
              path: 'register',
              builder: (context, state) => const RegisterPage(),
            ),
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) => const ForgotPasswordPage(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MainShell(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.addProperty,
          builder: (context, state) => const AddPropertyPage(),
        ),
        GoRoute(
          path: AppRoutes.propertyDetail,
          builder: (context, state) {
            final property = _resolveProperty(context, state);
            if (property == null) return const _MissingEntityPage(label: 'Mülk');
            return PropertyDetailPage(property: property);
          },
        ),
        GoRoute(
          path: AppRoutes.editProperty,
          builder: (context, state) {
            final property = _resolveProperty(context, state);
            return AddPropertyPage(property: property);
          },
        ),
        GoRoute(
          path: AppRoutes.addTenant,
          builder: (context, state) => const AddTenantPage(),
        ),
        GoRoute(
          path: AppRoutes.tenantDetail,
          builder: (context, state) {
            final tenant = _resolveTenant(context, state);
            if (tenant == null) {
              return const _MissingEntityPage(label: 'Kiracı');
            }
            return TenantDetailPage(tenant: tenant);
          },
        ),
        GoRoute(
          path: AppRoutes.editTenant,
          builder: (context, state) {
            final tenant = _resolveTenant(context, state);
            return AddTenantPage(tenant: tenant);
          },
        ),
        GoRoute(
          path: AppRoutes.tenantPayments,
          builder: (context, state) {
            final tenant = _resolveTenant(context, state);
            if (tenant == null) {
              return const _MissingEntityPage(label: 'Kiracı');
            }
            return TenantPaymentHistoryPage(tenant: tenant);
          },
        ),
        GoRoute(
          path: AppRoutes.addPayment,
          builder: (context, state) => const AddPaymentPage(),
        ),
      ],
    );
  }

  static String? _redirect({
    required AuthCubit authCubit,
    required AppRouterRefresh refresh,
    required String location,
  }) {
    if (!refresh.bootstrapped) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final authenticated = authCubit.state.isAuthenticated;

    if (location == AppRoutes.splash) {
      if (authenticated) return AppRoutes.home;
      if (refresh.isFirstLaunch) return AppRoutes.onboarding;
      return AppRoutes.authChoice;
    }

    if (!authenticated && !AppRoutes.isPublicLocation(location)) {
      return refresh.isFirstLaunch
          ? AppRoutes.onboarding
          : AppRoutes.authChoice;
    }

    if (authenticated && AppRoutes.isAuthLocation(location)) {
      return AppRoutes.home;
    }

    return null;
  }

  static Property? _resolveProperty(BuildContext context, GoRouterState state) {
    final id = state.pathParameters['propertyId'];
    if (id == null) return state.extra as Property?;
    return context.read<RentalCubit>().state.propertyById(id) ??
        state.extra as Property?;
  }

  static Tenant? _resolveTenant(BuildContext context, GoRouterState state) {
    final id = state.pathParameters['tenantId'];
    if (id == null) return state.extra as Tenant?;
    return context.read<RentalCubit>().state.tenantById(id) ??
        state.extra as Tenant?;
  }
}

class _MissingEntityPage extends StatelessWidget {
  const _MissingEntityPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('$label bulunamadı')),
    );
  }
}
