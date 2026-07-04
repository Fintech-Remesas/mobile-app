import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
            return Center(child: Text(state.message));
          }
          if (state is HistoryLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No hay transacciones aún'));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                
                bool showHeader = false;
                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevItem = state.items[index - 1];
                  if (item.date.month != prevItem.date.month || item.date.year != prevItem.date.year) {
                    showHeader = true;
                  }
                }
                
                final monthYearStr = "${_getMonthName(item.date.month)} ${item.date.year}";

                final tile = ListTile(
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => context.push('/transaction/${item.id}'),
                );

                if (showHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          monthYearStr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      tile,
                    ],
                  );
                }

                return tile;
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}
