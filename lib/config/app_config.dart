// lib/config/app_config.dart

class AppConfig {
  static const String appName = 'Wallet Hub';
  
  // URL du serveur SchoolHub Backend
  static const String baseUrl = 'https://schoolhub.cm'; // ou http://localhost:8000 pour tests web/desktop
  static const String prodUrl = 'https://schoolhub.cm';

  static String get apiBaseUrl => '$prodUrl/wallet/api/v1';

  // Pour le dev local via émulateur ou appareil
  static String activeBaseUrl = 'https://schoolhub.cm/wallet/api/v1';

  static String get activeRootUrl {
    if (activeBaseUrl.contains('/wallet/api/v1')) {
      return activeBaseUrl.replaceAll('/wallet/api/v1', '');
    }
    return baseUrl;
  }
}
