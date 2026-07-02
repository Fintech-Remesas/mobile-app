import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/remittance_status_mapper.dart';
import '../../../../theme/app_theme.dart';
import '../bloc/deposit_bloc.dart';

class DepositConfirmationPage extends StatefulWidget {
  final String id;

  const DepositConfirmationPage({super.key, required this.id});

  @override
  State<DepositConfirmationPage> createState() =>
      _DepositConfirmationPageState();
}

class _DepositConfirmationPageState extends State<DepositConfirmationPage> {
  Timer? _expiryTimer;
  Duration? _remaining;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _startExpiryCountdown(String? expiresAt) {
    _expiryTimer?.cancel();
    _remaining = null;
    if (expiresAt == null || expiresAt.isEmpty) return;

    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return;

    void tick() {
      final diff = expiry.difference(DateTime.now());
      if (!mounted) return;
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
      if (diff.isNegative) _expiryTimer?.cancel();
    }

    tick();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  String _formatRemaining(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours}:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar depósito')),
      body: BlocConsumer<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state is DepositConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Depósito confirmado')),
            );
            context.go('/transaction/${widget.id}');
          }

          final remittance = switch (state) {
            DepositLoaded(:final remittance) => remittance,
            DepositConfirming(:final remittance) => remittance,
            DepositConfirmed(:final remittance) => remittance,
            _ => null,
          };
          if (remittance?.expiresAt != null) {
            _startExpiryCountdown(remittance!.expiresAt);
          }
        },
        builder: (context, state) {
          if (state is DepositLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DepositError) {
            return Center(child: Text(state.message));
          }

          final remittance = switch (state) {
            DepositLoaded(:final remittance) => remittance,
            DepositConfirming(:final remittance) => remittance,
            DepositConfirmed(:final remittance) => remittance,
            _ => null,
          };

          if (remittance == null) {
            return const SizedBox.shrink();
          }

          final isConfirming = state is DepositConfirming;
          final depositCode = remittance.depositCode;
          final canConfirm =
              remittance.status.toUpperCase() == 'PENDING_DEPOSIT';
          final amountLabel = remittance.depositAmountPEN != null
              ? 'S/ ${remittance.depositAmountPEN!.toStringAsFixed(2)}'
              : remittance.amountUSD != null
                  ? '\$ ${remittance.amountUSD!.toStringAsFixed(2)}'
                  : '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 64,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Simula tu Yape',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                if (remittance.message != null && remittance.message!.isNotEmpty)
                  Text(
                    remittance.message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  )
                else
                  Text(
                    'Realiza un depósito con el código indicado para continuar '
                    'el proceso blockchain.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                const SizedBox(height: 32),
                _InfoCard(
                  label: 'Monto a depositar',
                  value: amountLabel,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Código de depósito',
                  value: depositCode ?? 'Código pendiente de backend',
                  onCopy: depositCode != null
                      ? () {
                          Clipboard.setData(ClipboardData(text: depositCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado')),
                          );
                        }
                      : null,
                ),
                if (_remaining != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'Tiempo restante',
                    value: _remaining == Duration.zero
                        ? 'Expirado'
                        : _formatRemaining(_remaining!),
                  ),
                ],
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'Estado',
                  value: RemittanceStatusMapper.label(remittance.status),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  label: 'ID remesa',
                  value: remittance.id,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isConfirming || !canConfirm
                        ? null
                        : () => context.read<DepositBloc>().add(
                              ConfirmDepositRequested(widget.id),
                            ),
                    child: isConfirming
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            canConfirm
                                ? 'Confirmar depósito (Yape)'
                                : 'Depósito no disponible',
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isConfirming
                      ? null
                      : () => context.push('/transaction/${widget.id}'),
                  child: const Text('Ver detalle de la remesa'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoCard({
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 20),
            ),
        ],
      ),
    );
  }
}
