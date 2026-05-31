import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/theme_local_data_source.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._localDataSource) : super(_localDataSource.getThemeMode());

  final ThemeLocalDataSource _localDataSource;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _localDataSource.saveThemeMode(themeMode);
    emit(themeMode);
  }
}
