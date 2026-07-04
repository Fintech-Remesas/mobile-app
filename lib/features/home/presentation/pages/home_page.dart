import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/home_bloc.dart';
import '../../../kyc/presentation/bloc/kyc_bloc.dart';
import '../../../kyc/domain/entities/kyc_status.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/ledger_movements_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<KycBloc, KycState>(
        builder: (context, kycState) {
          final isKycApproved =
              kycState is KycStatusLoaded && kycState.status == KycStatus.approved;

          return BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudo cargar la información',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<HomeBloc>().add(const LoadHome()),
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const RefreshHome());
                    await context.read<HomeBloc>().stream.firstWhere(
                          (s) =>
                              s is HomeLoaded && !s.isRefreshing || s is HomeError,
                        );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isKycApproved)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Verificación requerida',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Debes completar tu KYC para usar todas las funciones.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => context.go('/kyc-start'),
                                        child: const Text(
                                          'Verificar ahora',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Tarjeta de saldo — datos reales del ledger
                        BalanceCard(wallet: state.wallet),
                        const SizedBox(height: 24),
                        QuickActionsRow(enabled: isKycApproved),
                        const SizedBox(height: 32),
                        // Lista de transacciones — datos reales del ledger
                        LedgerMovementsList(movements: state.ledgerMovements),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
