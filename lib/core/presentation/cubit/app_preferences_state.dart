part of 'app_preferences_cubit.dart';

class AppPreferencesState extends Equatable {
  final ThemeMode themeMode;
  final String locale;

  const AppPreferencesState({
    this.themeMode = ThemeMode.light,
    this.locale = 'en',
  });

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    String? locale,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object> get props => [themeMode, locale];
}
