/// Uygulama rota path sabitleri.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  static const authChoice = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';

  static const home = '/';
  static const notifications = '/notifications';
  static const profile = '/profile';

  static const addProperty = '/properties/add';
  static const propertyDetail = '/properties/:propertyId';
  static const editProperty = '/properties/:propertyId/edit';

  static const addTenant = '/tenants/add';
  static const tenantDetail = '/tenants/:tenantId';
  static const editTenant = '/tenants/:tenantId/edit';
  static const tenantPayments = '/tenants/:tenantId/payments';

  static const addPayment = '/payments/add';

  static String propertyDetailPath(String propertyId) =>
      '/properties/$propertyId';

  static String editPropertyPath(String propertyId) =>
      '/properties/$propertyId/edit';

  static String tenantDetailPath(String tenantId) => '/tenants/$tenantId';

  static String editTenantPath(String tenantId) => '/tenants/$tenantId/edit';

  static String tenantPaymentsPath(String tenantId) =>
      '/tenants/$tenantId/payments';

  static bool isAuthLocation(String location) =>
      location == authChoice ||
      location == login ||
      location == register ||
      location == forgotPassword ||
      location == onboarding;

  static bool isPublicLocation(String location) =>
      location == splash || isAuthLocation(location);
}
