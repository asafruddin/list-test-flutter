import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:showcase_list_test/features/settings/data/theme_local_data_source.dart';
import 'package:showcase_list_test/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:showcase_list_test/features/settings/presentation/pages/settings_page.dart';

void main() {
  group('SettingsPage', () {
    late Box<dynamic> box;
    late ThemeCubit themeCubit;

    setUp(() async {
      Hive.init('./.dart_tool/test_hive_settings_page');
      box = await Hive.openBox<dynamic>('settings_page_test');
      await box.clear();
      themeCubit = ThemeCubit(ThemeLocalDataSource(box));
    });

    tearDown(() async {
      await themeCubit.close();
      await box.close();
      await Hive.deleteBoxFromDisk('settings_page_test');
    });

    testWidgets('changes theme mode', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: themeCubit,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );

      await tester.runAsync(() async {
        segmentedButton.onSelectionChanged!({ThemeMode.dark});
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(themeCubit.state, ThemeMode.dark);
      expect(box.get('theme_mode'), 'dark');
    });
  });
}
