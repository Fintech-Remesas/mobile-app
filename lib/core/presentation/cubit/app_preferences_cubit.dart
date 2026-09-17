import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_preferences_state.dart';

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit() : super(const AppPreferencesState());

  void toggleTheme(bool isDark) {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void changeLanguage(String languageCode) {
    emit(state.copyWith(locale: languageCode));
  }
}
