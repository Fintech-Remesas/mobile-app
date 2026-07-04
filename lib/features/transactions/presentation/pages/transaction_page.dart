import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/web3_transfer_bloc.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<Web3TransferBloc>(),
      child: const TransactionView(),
    );
  }
}

class TransactionView extends StatefulWidget {
  const TransactionView({super.key});

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferir Dinero')),
      body: BlocConsumer<Web3TransferBloc, Web3TransferState>(
        listener: (context, state) {
          if (state is TransferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TransferInitial || state is TransferSearchLoading || state is TransferSearchLoaded) {
            return _buildSearchStep(context, state);
          } else if (state is TransferUserSelected || state is TransferQuoteLoading) {
            return _buildAmountStep(context, state);
          } else if (state is TransferQuoteLoaded || state is TransferConfirming) {
            return _buildConfirmStep(context, state);
          } else if (state is TransferTracking) {
            return _buildTrackingStep(context, state);
          } else if (state is TransferError) {
            final bloc = context.read<Web3TransferBloc>();
            if (bloc.selectedUser == null) {
              return _buildSearchStep(context, state);
            } else if (bloc.quote == null) {
              return _buildAmountStep(context, state);
            } else if (bloc.remittance == null) {
              return _buildConfirmStep(context, state);
            } else {
              return _buildTrackingStep(context, state);
            }
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
    );
  }

  Widget _buildSearchStep(BuildContext context, Web3TransferState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buscar Destinatario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Nombre, Email o Teléfono',
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.search),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    context.read<Web3TransferBloc>().add(SearchUsersEvent(_searchController.text));
                  }
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<Web3TransferBloc>().add(SearchUsersEvent(value));
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSearchResults(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Web3TransferState state) {
    if (state is TransferSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is TransferSearchLoaded) {
      if (state.users.isEmpty) {
        return const Center(child: Text('No se encontraron usuarios'));
      }
      return ListView.builder(
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user.firstName.isNotEmpty ? user.firstName[0] : '?')),
            title: Text(user.fullName),
            subtitle: Text(user.email),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () {
              context.read<Web3TransferBloc>().add(SelectUserEvent(user));
            },
          );
        },
      );
    }
    return const Center(child: Text('Busca un usuario para transferir'));
  }

  Widget _buildAmountStep(BuildContext context, Web3TransferState state) {
    bool isLoading = state is TransferQuoteLoading;
    final user = (state is TransferUserSelected) ? state.selectedUser : (state as TransferQuoteLoading).selectedUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresar Monto (USD)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Destinatario: ${user.fullName}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto en USD',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  context.read<Web3TransferBloc>().add(RequestQuoteEvent(amount));
                }
              },
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Obtener Cotización'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConfirmStep(BuildContext context, Web3TransferState state) {
    bool isConfirming = state is TransferConfirming;
    final quote = state is TransferQuoteLoaded ? state.quote : (state as TransferConfirming).quote;
    final user = state is TransferQuoteLoaded ? state.selectedUser : (state as TransferConfirming).selectedUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirmar Cotización', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow('Destinatario', user.fullName),
                  const Divider(),
                  _buildDetailRow('Envías (USD)', '\$${quote.amountUSD.toStringAsFixed(2)}'),
                  _buildDetailRow('Tasa de cambio', 'S/ ${quote.exchangeRate.toStringAsFixed(4)}'),
                  _buildDetailRow('Comisión (${(quote.fee * 100).toStringAsFixed(0)}%)', '-\$${quote.feeAmount.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildDetailRow('Total a Pagar (USD)', '\$${quote.amountSourceCurrency.toStringAsFixed(2)}', isBold: true),
                  _buildDetailRow('Recibe (PEN)', 'S/ ${quote.amountDestination.toStringAsFixed(2)}', isBold: true, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: isConfirming ? null : () {
                context.read<Web3TransferBloc>().add(const ConfirmTransferEvent());
              },
              child: isConfirming ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirmar Transferencia'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrackingStep(BuildContext context, Web3TransferState state) {
    final trackingState = state as TransferTracking;
    final remittance = trackingState.remittance;
    final timeline = trackingState.timeline;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de la Transferencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Remesa ID: ${remittance.remittanceId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (timeline != null && timeline.txHash != null)
            Text('TxHash: ${timeline.txHash}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: timeline == null 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: timeline.steps.length,
                  itemBuilder: (context, index) {
                    final step = timeline.steps[index];
                    Color statusColor = Colors.grey;
                    IconData statusIcon = LucideIcons.circle;
                    
                    if (step.status == 'completed') {
                      statusColor = Colors.green;
                      statusIcon = LucideIcons.checkCircle2;
                    } else if (step.status == 'in_progress') {
                      statusColor = Colors.orange;
                      statusIcon = LucideIcons.loader;
                    }

                    return ListTile(
                      leading: Icon(statusIcon, color: statusColor),
                      title: Text(step.label, style: TextStyle(fontWeight: step.status == 'completed' || step.status == 'in_progress' ? FontWeight.bold : FontWeight.normal)),
                      subtitle: step.detail != null ? Text(step.detail!) : null,
                      trailing: step.status == 'in_progress' ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                    );
                  },
                ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<Web3TransferBloc>().add(LoadTimelineEvent(remittance.remittanceId));
              },
              child: const Text('Actualizar Estado'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
