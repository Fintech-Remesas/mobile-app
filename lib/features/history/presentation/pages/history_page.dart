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
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
