import 'package:flutter_test/flutter_test.dart';
import 'package:showcase_list_test/app/app_flavor.dart';
import 'package:showcase_list_test/core/constants/api_constants.dart';

void main() {
  group('AppFlavor', () {
    test('falls back to production for empty and unknown values', () {
      expect(AppFlavor.fromName(''), AppFlavor.production);
      expect(AppFlavor.fromName('unknown'), AppFlavor.production);
    });

    test('resolves tenant from name', () {
      expect(AppFlavor.fromName('tenant'), AppFlavor.tenant);
      expect(AppFlavor.fromName(' TENANT '), AppFlavor.tenant);
    });
  });

  group('AppFlavorConfig', () {
    test('creates production config', () {
      final config = AppFlavorConfig.fromFlavor(AppFlavor.production);

      expect(config.flavor, AppFlavor.production);
      expect(config.appTitle, 'Showcase Posts');
      expect(config.baseUrl, ApiConstants.baseUrl);
    });

    test('creates tenant config', () {
      final config = AppFlavorConfig.fromFlavor(AppFlavor.tenant);

      expect(config.flavor, AppFlavor.tenant);
      expect(config.appTitle, 'Showcase Posts Tenant');
      expect(config.baseUrl, ApiConstants.baseUrl);
    });
  });
}
