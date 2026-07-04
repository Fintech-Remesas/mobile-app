import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection_container.dart';
import '../../core/widgets/main_layout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
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
import '../../features/transactions/presentation/pages/deposit_money_page.dart';
import '../../features/transactions/presentation/pages/transaction_page.dart';
import '../../features/transactions/presentation/pages/withdraw_money_page.dart';

// ... other imports ...
import '../../features/transactions/presentation/bloc/transaction_detail_bloc.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/payment_methods/presentation/bloc/add_bank_account_bloc.dart';
import '../../features/payment_methods/presentation/bloc/add_card_bloc.dart';
import '../../features/payment_methods/presentation/bloc/bank_accounts_list_bloc.dart';
import '../../features/payment_methods/presentation/bloc/cards_list_bloc.dart';
import '../../features/payment_methods/presentation/pages/add_bank_account_page.dart';
import '../../features/payment_methods/presentation/pages/add_card_page.dart';
import '../../features/payment_methods/presentation/pages/bank_accounts_page.dart';
import '../../features/payment_methods/presentation/pages/cards_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<AuthBloc>()),
          BlocProvider.value(value: sl<KycBloc>()),
          BlocProvider(create: (_) => sl<AddBankAccountBloc>()),
          BlocProvider(create: (_) => sl<AddCardBloc>()),
        ],
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
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
      builder: (context, state) => BlocProvider.value(
        value: sl<KycBloc>(),
        child: const KycStartPage(),
      ),
    ),
    GoRoute(
      path: '/kyc-pending',
      builder: (context, state) => BlocProvider.value(
        value: sl<KycBloc>(),
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
      builder: (context, state, child) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: sl<KycBloc>()),
          BlocProvider(create: (_) => sl<HomeBloc>()),
        ],
        child: MainLayout(child: child),
      ),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/transaction',
          builder: (context, state) => const TransactionPage(),
        ),
        GoRoute(
          path: '/deposit',
          builder: (context, state) => const DepositMoneyPage(),
        ),
        GoRoute(
          path: '/withdraw',
          builder: (context, state) => const WithdrawMoneyPage(),
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
    GoRoute(
      path: '/cards',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CardsListBloc>(),
        child: const CardsPage(),
      ),
    ),
    GoRoute(
      path: '/bank-accounts',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BankAccountsListBloc>(),
        child: const BankAccountsPage(),
      ),
    ),
    GoRoute(
      path: '/add-card',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AddCardBloc>(),
        child: const AddCardPage(),
      ),
    ),
    GoRoute(
      path: '/add-bank-account',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AddBankAccountBloc>(),
        child: const AddBankAccountPage(),
      ),
    ),
  ],
);
