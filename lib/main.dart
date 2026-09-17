import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/routes/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/localization/app_localizations.dart';
import 'core/presentation/cubit/app_preferences_cubit.dart';
import 'theme/app_theme.dart';
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await init();
  runApp(const FintechRemittanceApp());
}


class FintechRemittanceApp extends StatelessWidget {
  const FintechRemittanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppPreferencesCubit(),
      child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Sagiro Remittance App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: Locale(state.locale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
            ],
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
