import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/detail_info_row.dart';
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

  static String _truncateId(String value) {
    if (value.length <= 20) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 6)}';
  }

  void _copyId(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.accentGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$amountPrefix\$$amountValue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 32),
                  DetailInfoRow(
                    centered: true,
                    label: 'Status',
                    child: Text(
                      detail.status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DetailInfoRow(
                    centered: true,
                    label: 'To',
                    child: Text(
                      detail.recipient,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DetailInfoRow(
                    centered: true,
                    label: 'Transaction ID',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _truncateId(detail.id),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: AppTheme.primaryBlue,
                          tooltip: 'Copiar ID',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _copyId(context, detail.id),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PolygonNodeCard(
                    transactionHash: detail.transactionHash,
                    network: _mapNetwork(detail.network),
                    blockNumber: detail.blockNumber,
                    status: _mapStatus(detail.confirmationStatus),
                    blockTimestamp: detail.blockTimestamp,
                    polygonscanUrl: detail.polygonscanUrl,
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
