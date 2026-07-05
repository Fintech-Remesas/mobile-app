import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/home')) currentIndex = 0;
    if (location.startsWith('/transaction') || location.startsWith('/deposit') || location.startsWith('/withdraw')) {
      currentIndex = 1;
    }
    if (location.startsWith('/history')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              if (currentIndex == 0) {
                context.read<HomeBloc>().add(const RefreshHome());
              }
              context.go('/home');
            case 1:
              context.go('/transaction');
            case 2:
              if (currentIndex == 2) {
                context.read<HistoryBloc>().add(const RefreshHistory());
              }
              context.go('/history');
            case 3:
              context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.arrowUpCircle), label: 'Transacción'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
