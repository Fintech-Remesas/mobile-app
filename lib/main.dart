import 'package:flutter/material.dart';

import 'config/routes/app_router.dart';
import 'core/di/injection_container.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
