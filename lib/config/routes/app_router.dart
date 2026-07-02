import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_refresh_notifier.dart';
import '../../core/di/injection_container.dart';
import '../../core/storage/token_storage.dart';
import '../../core/widgets/main_layout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/bank_accounts/presentation/bloc/bank_account_bloc.dart';
import '../../features/bank_accounts/presentation/pages/bank_accounts_page.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/kyc/presentation/bloc/kyc_bloc.dart';
import '../../features/kyc/presentation/pages/kyc_approved_page.dart';
import '../../features/kyc/presentation/pages/kyc_pending_page.dart';
import '../../features/kyc/presentation/pages/kyc_rejected_page.dart';
import '../../features/kyc/presentation/pages/kyc_start_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/pages/limits_page.dart';
import '../../features/settings/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/security_page.dart';
import '../../features/transactions/presentation/bloc/deposit_bloc.dart';
import '../../features/transactions/presentation/bloc/send_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_detail_bloc.dart';
import '../../features/transactions/presentation/pages/deposit_confirmation_page.dart';
import '../../features/transactions/presentation/pages/receive_money_page.dart';
import '../../features/transactions/presentation/pages/send_money_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

const _publicRoutes = {
  '/',
  '/register',
  '/login',
  '/verify-otp',
};

const _authRoutes = {
  '/kyc-start',
  '/kyc-pending',
  '/kyc-approved',
  '/kyc-rejected',
};

const _protectedRoutes = {
  '/home',
  '/send',
  '/receive',
  '/history',
  '/profile',
  '/bank-accounts',
  '/notifications',
  '/limits',
  '/security',
};

GoRouter createAppRouter() => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: sl<AuthRefreshNotifier>(),
  redirect: (context, state) async {
    final tokenStorage = sl<TokenStorage>();
    final token = await tokenStorage.getAccessToken();
    final hasToken = token != null && token.isNotEmpty;
    final location = state.matchedLocation;
    final isPublic = _publicRoutes.contains(location);
    final isAuthFlow = _authRoutes.contains(location);
    final isProtected = _protectedRoutes.contains(location) ||
        location.startsWith('/transaction/');

    if (!hasToken) {
      if (isPublic) return null;
      return '/';
    }

    if (location == '/' || location == '/login' || location == '/register') {
      final canOperate = await tokenStorage.getCanOperate();
      return canOperate ? '/home' : '/kyc-start';
    }

    if (isProtected || isAuthFlow) {
      final canOperate = await tokenStorage.getCanOperate();
      if (!canOperate && !isAuthFlow && location != '/kyc-start') {
        return '/kyc-start';
      }
      if (canOperate && isAuthFlow) {
        return '/home';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final sessionExpired =
            state.uri.queryParameters['sessionExpired'] == '1';
        return BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: LoginPage(sessionExpired: sessionExpired),
        );
      },
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const VerifyOtpPage(),
      ),
    ),
    GoRoute(
      path: '/kyc-start',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<KycBloc>(),
        child: const KycStartPage(),
      ),
    ),
    GoRoute(
      path: '/kyc-pending',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<KycBloc>(),
        child: const KycPendingPage(),
      ),
    ),
    GoRoute(
      path: '/kyc-approved',
      builder: (context, state) => const KycApprovedPage(),
    ),
    GoRoute(
      path: '/kyc-rejected',
      builder: (context, state) => const KycRejectedPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<HomeBloc>(),
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/send',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SendBloc>(),
            child: const SendMoneyPage(),
          ),
        ),
        GoRoute(
          path: '/receive',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<BankAccountBloc>(),
            child: const ReceiveMoneyPage(),
          ),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<HistoryBloc>(),
            child: const HistoryPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<ProfileBloc>(),
            child: const ProfilePage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/bank-accounts',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BankAccountBloc>(),
        child: const BankAccountsPage(),
      ),
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return BlocProvider(
          create: (_) => sl<TransactionDetailBloc>()..add(LoadTransactionDetail(id)),
          child: TransactionDetailPage(id: id),
        );
      },
    ),
    GoRoute(
      path: '/transaction/:id/deposit',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return BlocProvider(
          create: (_) => sl<DepositBloc>()..add(LoadDeposit(id)),
          child: DepositConfirmationPage(id: id),
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SettingsBloc>()..add(const LoadNotifications()),
        child: const NotificationsPage(),
      ),
    ),
    GoRoute(
      path: '/limits',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SettingsBloc>()..add(const LoadLimits()),
        child: const LimitsPage(),
      ),
    ),
    GoRoute(
      path: '/security',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SettingsBloc>()..add(const LoadSecuritySettings()),
        child: const SecurityPage(),
      ),
    ),
  ],
);

GoRouter? _appRouter;

GoRouter get appRouter => _appRouter ??= createAppRouter();

void initAppRouter() {
  _appRouter ??= createAppRouter();
}

void handleSessionExpired(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')),
  );
  context.go('/login?sessionExpired=1');
}
