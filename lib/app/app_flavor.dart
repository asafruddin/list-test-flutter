import '../core/constants/api_constants.dart';

enum AppFlavor {
  production,
  tenant;

  static AppFlavor fromName(String value) {
    return switch (value.trim().toLowerCase()) {
      'tenant' => AppFlavor.tenant,
      _ => AppFlavor.production,
    };
  }
}

class AppFlavorConfig {
  const AppFlavorConfig({
    required this.flavor,
    required this.appTitle,
    required this.baseUrl,
  });

  factory AppFlavorConfig.fromFlavor(AppFlavor flavor) {
    return switch (flavor) {
      AppFlavor.production => const AppFlavorConfig(
        flavor: AppFlavor.production,
        appTitle: 'Showcase Posts',
        baseUrl: ApiConstants.baseUrl,
      ),
      AppFlavor.tenant => const AppFlavorConfig(
        flavor: AppFlavor.tenant,
        appTitle: 'Showcase Posts Tenant',
        baseUrl: ApiConstants.baseUrl,
      ),
    };
  }

  static const _flavorName = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'production',
  );

  static AppFlavorConfig get current {
    return AppFlavorConfig.fromFlavor(AppFlavor.fromName(_flavorName));
  }

  final AppFlavor flavor;
  final String appTitle;
  final String baseUrl;
}
