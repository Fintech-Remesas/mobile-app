import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/polygon_node_card.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/transaction_detail_bloc.dart';

class TransactionDetailPage extends StatelessWidget {
  final String id;

  const TransactionDetailPage({super.key, required this.id});

  PolygonNetwork _mapNetwork(String network) {
    return network == 'mainnet'
        ? PolygonNetwork.mainnet
        : PolygonNetwork.amoyTestnet;
  }

  PolygonConfirmationStatus _mapStatus(String status) {
    return status == 'confirmed'
        ? PolygonConfirmationStatus.confirmed
        : PolygonConfirmationStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionDetailError) {
            return Center(child: Text(state.message));
          }
          if (state is TransactionDetailLoaded) {
            final detail = state.detail;
            final amountPrefix = detail.amount >= 0 ? '+' : '-';
            final amountValue = detail.amount.abs().toStringAsFixed(2);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 64, color: AppTheme.accentGreen),
                  const SizedBox(height: 16),
                  Text(
                    '$amountPrefix\$$amountValue',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    title: const Text('Status'),
                    trailing: Text(
                      detail.status,
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('To'),
                    trailing: Text(detail.recipient),
                  ),
                  ListTile(
                    title: const Text('Transaction ID'),
                    trailing: Text('TRX-${detail.id}'),
                  ),
                  const SizedBox(height: 24),
                  PolygonNodeCard(
                    transactionHash: detail.transactionHash,
                    network: _mapNetwork(detail.network),
                    blockNumber: detail.blockNumber,
                    status: _mapStatus(detail.confirmationStatus),
                    blockTimestamp: detail.blockTimestamp,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
