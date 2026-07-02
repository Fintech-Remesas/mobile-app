import 'package:flutter/material.dart';

import 'config/routes/app_router.dart';
import 'core/auth/auth_refresh_notifier.dart';
import 'core/di/injection_container.dart';
import 'core/storage/token_storage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  initAppRouter();
  runApp(const FintechRemittanceApp());
}

class FintechRemittanceApp extends StatefulWidget {
  const FintechRemittanceApp({super.key});

  @override
  State<FintechRemittanceApp> createState() => _FintechRemittanceAppState();
}

class _FintechRemittanceAppState extends State<FintechRemittanceApp> {
  late final AuthRefreshNotifier _authRefreshNotifier;

  @override
  void initState() {
    super.initState();
    _authRefreshNotifier = sl<AuthRefreshNotifier>();
    _authRefreshNotifier.addListener(_onAuthRefresh);
  }

  @override
  void dispose() {
    _authRefreshNotifier.removeListener(_onAuthRefresh);
    super.dispose();
  }

  Future<void> _onAuthRefresh() async {
    final token = await sl<TokenStorage>().getAccessToken();
    if (token == null || token.isEmpty) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        handleSessionExpired(context);
      }
    }
  }

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
