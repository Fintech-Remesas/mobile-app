import 'dart:io';
import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'core/di/injection_container.dart';
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
    return MaterialApp.router(
      title: 'Sagiro Remittance App',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
