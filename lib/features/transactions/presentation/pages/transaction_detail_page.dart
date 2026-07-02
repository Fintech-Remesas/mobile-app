import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/remittance_status_mapper.dart';
import '../../../../core/widgets/detail_info_row.dart';
import '../../../../core/widgets/polygon_node_card.dart';
import '../../../../core/widgets/remittance_timeline_steps.dart';
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
    if (status == 'confirmed') {
      return PolygonConfirmationStatus.confirmed;
    }
    return PolygonConfirmationStatus.pending;
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
      appBar: AppBar(
        title: const Text('Detalle de remesa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<TransactionDetailBloc>()
                .add(const RefreshTransactionDetail()),
          ),
        ],
      ),
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
            final needsDeposit = RemittanceStatusMapper.needsDeposit(detail.status);
            final isFailed = detail.status.toUpperCase().contains('FAILED');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isFailed
                        ? Icons.error_outline
                        : detail.confirmationStatus == 'confirmed'
                            ? Icons.check_circle
                            : Icons.schedule,
                    size: 64,
                    color: isFailed
                        ? Colors.red
                        : detail.confirmationStatus == 'confirmed'
                            ? AppTheme.accentGreen
                            : AppTheme.primaryBlue,
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
                    label: 'Estado',
                    child: Text(
                      detail.statusLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isFailed ? Colors.red : AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (detail.errorMessage != null &&
                      detail.errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        detail.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  DetailInfoRow(
                    centered: true,
                    label: 'Para',
                    child: Text(
                      detail.recipient,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (detail.depositCode != null &&
                      detail.depositCode!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailInfoRow(
                      centered: true,
                      label: 'Código depósito',
                      child: Text(
                        detail.depositCode!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  DetailInfoRow(
                    centered: true,
                    label: 'ID remesa',
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
                  if (needsDeposit) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/transaction/$id/deposit'),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Ir a confirmar depósito'),
                      ),
                    ),
                  ],
                  if (detail.timelineSteps.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    RemittanceTimelineSteps(steps: detail.timelineSteps),
                  ],
                  const SizedBox(height: 24),
                  if (detail.hasTransactionHash)
                    PolygonNodeCard(
                      transactionHash: detail.transactionHash!,
                      network: _mapNetwork(detail.network),
                      blockNumber: detail.blockNumber,
                      status: _mapStatus(detail.confirmationStatus),
                      blockTimestamp: detail.blockTimestamp,
                      polygonscanUrl: detail.polygonscanUrl,
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          if (detail.isPolling)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          Text(
                            'Procesando transacción blockchain...',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        ],
                      ),
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
