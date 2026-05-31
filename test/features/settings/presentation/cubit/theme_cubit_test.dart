import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:showcase_list_test/features/settings/data/theme_local_data_source.dart';
import 'package:showcase_list_test/features/settings/presentation/cubit/theme_cubit.dart';

void main() {
  group('ThemeCubit', () {
    late Box<dynamic> box;

    setUp(() async {
      Hive.init('./.dart_tool/test_hive_theme');
      box = await Hive.openBox<dynamic>('settings_test');
      await box.clear();
    });

    tearDown(() async {
      await box.close();
      await Hive.deleteBoxFromDisk('settings_test');
    });

    test('loads system theme by default', () {
      final cubit = ThemeCubit(ThemeLocalDataSource(box));

      expect(cubit.state, ThemeMode.system);
      cubit.close();
    });

    test('persists and emits selected theme mode', () async {
      final cubit = ThemeCubit(ThemeLocalDataSource(box));

      await cubit.setThemeMode(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      expect(box.get('theme_mode'), 'dark');
      await cubit.close();
    });
  });
}
