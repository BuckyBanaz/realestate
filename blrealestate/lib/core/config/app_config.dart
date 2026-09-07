// Description: Centralized app configuration — all environment-specific values live here.
// Why: Previously the server IP was hardcoded in 4 different files, mixing HTTP and HTTPS.
//      One change here now propagates everywhere: API, image URLs, and WebView pages.
//      When moving to production, only this file needs to change.
class AppConfig {
  AppConfig._();

  // ── Server Base ──────────────────────────────────────────────────────────────
  // Switch this single line when moving from dev server to production domain.
  static const String _serverBase = 'hisarpropertybazar.com';
//old base url = "'108.181.185.27';"

  // ── API ──────────────────────────────────────────────────────────────────────
  static const String apiBaseUrl = 'https://$_serverBase/blapis/api';

  // ── Image CDN ────────────────────────────────────────────────────────────────
  // Previously these used plain HTTP in app_models.dart:461-462.
  // Updated to HTTPS — consistent with the API and required on iOS.
  static const String propertyImageBase =
      'https://$_serverBase/bladmin/public/uploads/properties/';
  static const String categoryImageBase =
      'https://$_serverBase/bladmin/public/uploads/categories/';

  // ── Web (Frontend) Pages ─────────────────────────────────────────────────────
  // Used by the WebView in profile_screen.dart.
  // Previously used plain HTTP — updated to HTTPS.
  static const String contactUrl    = 'https://$_serverBase/blfront/contact';
  static const String privacyUrl    = 'https://$_serverBase/blfront/privacy-policy';
  static const String termsUrl      = 'https://$_serverBase/blfront/terms-service';
}
