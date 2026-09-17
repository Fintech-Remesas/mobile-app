import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/presentation/cubit/app_preferences_cubit.dart';

class AppPreferencesPage extends StatelessWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final prefsCubit = context.watch<AppPreferencesCubit>();
    final isDark = prefsCubit.state.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('general_settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(loc.translate('dark_mode')),
            value: isDark,
            onChanged: (value) {
              context.read<AppPreferencesCubit>().toggleTheme(value);
            },
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.translate('language')),
            trailing: DropdownButton<String>(
              value: prefsCubit.state.locale,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(loc.translate('english')),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text(loc.translate('spanish')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<AppPreferencesCubit>().changeLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
