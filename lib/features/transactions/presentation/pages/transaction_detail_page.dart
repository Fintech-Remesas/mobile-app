import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/polygon_node_card.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/transaction_detail_bloc.dart';
import '../widgets/traceability_metrics_view.dart';
import '../../data/models/web3/remittance_model.dart';

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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isCopyable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: isCopyable ? () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            } : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.copy, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                ],
              ],
            ),
          ),
        ),
      ],
    );
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: detail.amount >= 0 ? AppTheme.accentGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      detail.amount >= 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                      size: 48, 
                      color: detail.amount >= 0 ? AppTheme.accentGreen : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$amountPrefix\$$amountValue USDC',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.status.toUpperCase(),
                    style: TextStyle(
                      color: detail.status.toLowerCase() == 'completed' 
                          ? AppTheme.accentGreen 
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Detalle Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(context, 'Fecha', _formatDate(detail.blockTimestamp)),
                        const Divider(height: 32),
                        _buildDetailRow(context, 'Concepto', detail.recipient),
                        const Divider(height: 32),
                        _buildDetailRow(context, 'ID de Transacción', detail.id, isCopyable: true),
                      ],
                    ),
                  ),

                  if (detail.transactionHash.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    PolygonNodeCard(
                      transactionHash: detail.transactionHash,
                      network: _mapNetwork(detail.network),
                      blockNumber: detail.blockNumber,
                      status: _mapStatus(detail.confirmationStatus),
                      blockTimestamp: detail.blockTimestamp,
                    ),
                  ],
                  
                  if (detail.status.toLowerCase() == 'completed' || detail.transactionHash.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6200EE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: const Color(0xFF6200EE).withOpacity(0.4),
                        ),
                        icon: const Icon(Icons.bar_chart, size: 24),
                        label: const Text('Ver Métricas de Trazabilidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        onPressed: () {
                          final mockRemittance = RemittanceModel(
                            remittanceId: detail.id,
                            depositCode: '',
                            amountUSD: detail.amount.abs(),
                            feeAmount: 0,
                            amountDestination: detail.amount.abs(),
                            amountSourceCurrency: 0,
                            message: '',
                            status: detail.status,
                            txHash: detail.transactionHash,
                            blockchainTxHash: detail.transactionHash,
                            blockNumber: detail.blockNumber,
                          );
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TraceabilityMetricsView(
                              remittance: mockRemittance,
                              timeline: null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
