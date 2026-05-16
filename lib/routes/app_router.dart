import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_screens.dart';
import '../screens/kyc_screens.dart';
import '../screens/dashboard_screens.dart';
import '../screens/transaction_screens.dart';
import '../screens/settings_screens.dart';
import '../screens/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => WelcomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => VerifyOTPScreen(),
    ),
    GoRoute(
      path: '/kyc-start',
      builder: (context, state) => KYCScreen(),
    ),
    GoRoute(
      path: '/kyc-pending',
      builder: (context, state) => KYCPendingScreen(),
    ),
    GoRoute(
      path: '/kyc-approved',
      builder: (context, state) => KYCApprovedScreen(),
    ),
    GoRoute(
      path: '/kyc-rejected',
      builder: (context, state) => KYCRejectedScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/send',
          builder: (context, state) => SendMoneyScreen(),
        ),
        GoRoute(
          path: '/receive',
          builder: (context, state) => ReceiveMoneyScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => HistoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/transaction/:id',
      builder: (context, state) => TransactionDetailScreen(id: state.pathParameters['id'] ?? 'unknown'),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => NotificationsScreen(),
    ),
    GoRoute(
      path: '/limits',
      builder: (context, state) => LimitsScreen(),
    ),
    GoRoute(
      path: '/security',
      builder: (context, state) => SecurityScreen(),
    ),
  ],
);
