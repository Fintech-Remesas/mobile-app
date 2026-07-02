import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../domain/entities/history_page.dart';
import '../bloc/history_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryError) {
            return ErrorStateView(
              heading: 'No se pudo cargar el historial',
              message: state.message,
              statusCode: state.statusCode,
              title: state.title,
              endpoint: state.endpoint,
              hint: state.hint,
              onRetry: () => context.read<HistoryBloc>().add(const LoadHistory()),
            );
          }
          if (state is HistoryLoaded) {
            if (state.items.isEmpty) {
              return EmptyStateView(
                icon: LucideIcons.history,
                title: 'Historial vacío',
                subtitle: 'Aún no tienes transacciones registradas.',
                actionLabel: 'Enviar dinero',
                onAction: () => context.push('/send'),
              );
            }
            return Column(
              children: [
                if (state.summary != null) _SummaryBanner(summary: state.summary!),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.items.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: state.isLoadingMore
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: [
                                    if (state.loadMoreError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          state.loadMoreError!,
                                          style: const TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    OutlinedButton(
                                      onPressed: () => context
                                          .read<HistoryBloc>()
                                          .add(const LoadMoreHistory()),
                                      child: const Text('Cargar más'),
                                    ),
                                  ],
                                ),
                        );
                      }
                      final item = state.items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            item.isOutgoing
                                ? LucideIcons.arrowUpRight
                                : LucideIcons.arrowDownLeft,
                          ),
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.subtitle),
                        trailing: Text(
                          '${item.isOutgoing ? '-' : '+'}\$${item.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: item.isOutgoing ? Colors.red : Colors.green,
                          ),
                        ),
                        onTap: () => context.push('/transaction/${item.id}'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final RemittanceSummary summary;

  const _SummaryBanner({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen (página actual)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: \$${summary.totalAmountUSD.toStringAsFixed(2)} · '
            'Completadas: ${summary.completedCount} · '
            'Fallidas: ${summary.failedCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Los totales del resumen corresponden solo a la página visible.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}
