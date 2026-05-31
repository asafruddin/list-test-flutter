import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ThemeLocalDataSource {
  ThemeLocalDataSource(this._box);

  static const _themeModeKey = 'theme_mode';

  final Box<dynamic> _box;

  ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey) as String?;

    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _box.put(_themeModeKey, themeMode.name);
  }
}
