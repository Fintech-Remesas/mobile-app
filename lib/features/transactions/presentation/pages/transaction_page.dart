import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/web3_transfer_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

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
            if (state.previousState is TransferConfirming || (bloc.quote != null && bloc.selectedUser != null && bloc.remittance == null)) {
              return _buildConfirmStep(context, state);
            }
            if (bloc.selectedUser == null) {
              return _buildSearchStep(context, state);
            } else if (bloc.quote == null) {
              return _buildAmountStep(context, state);
            } else if (bloc.remittance != null) {
              return _buildTrackingStep(context, TransferTracking(bloc.remittance!, null));
            } else {
              return _buildConfirmStep(context, state);
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
    final user = context.read<Web3TransferBloc>().selectedUser;
    if (user == null) return const SizedBox();

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
    final bloc = context.read<Web3TransferBloc>();
    final quote = bloc.quote;
    final user = bloc.selectedUser;
    if (quote == null || user == null) {
      return const Center(child: Text('Datos incompletos. Vuelve a iniciar la transferencia.'));
    }

    final bool isConfirming = state is TransferConfirming;

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
                  _buildDetailRow('Precio USDC', '\$${quote.usdcPrice.toStringAsFixed(2)}'),
                  _buildDetailRow('Comisión Sagiro (${(quote.commissionPct * 100).toStringAsFixed(1)}%)', '-\$${quote.feeAmount.toStringAsFixed(2)}'),
                  _buildDetailRow('Gas Polygon (USD)', '-\$${quote.gasFee.toStringAsFixed(4)}'),
                  const Divider(),
                  _buildDetailRow('Recibe el destinatario (USD)', '\$${quote.amountReceivedUSD.toStringAsFixed(2)}', isBold: true, color: Colors.green),
                  _buildDetailRow('Equivalente local', 'S/ ${(quote.amountReceivedUSD * quote.exchangeRate).toStringAsFixed(2)}'),
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
                final profileState = context.read<ProfileBloc>().state;
                final senderName = profileState is ProfileLoaded ? profileState.profile.name : 'Usuario';
                context.read<Web3TransferBloc>().add(ConfirmTransferEvent(senderName));
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
          _buildDetailRow('Monto Transferido:', '\$${remittance.amountUSD.toStringAsFixed(2)} USDC', isBold: true, color: Colors.green),
          _buildDetailRow('Cuenta Destino:', remittance.recipientName ?? 'Receptor', isBold: true),
          const Divider(),
          Text('Wallet Origen (EE.UU. - ${remittance.senderName ?? 'Usuario'}):', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Text('0x91c8AE9c06dF2a431E16664e3459F157C910827F', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('Wallet Destino (Perú - ${remittance.recipientName ?? 'Receptor'}):', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Text('0xcb3E3A9AF0D72786172fCeb2E27Ab835504daA00', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(),
          Text('Remesa ID: ${remittance.remittanceId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (timeline != null) ...[
            Text('Estado: ${timeline.currentStatus}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (timeline.explorerUrl != null)
              InkWell(
                onTap: () => _copyTxHash(context, timeline.explorerUrl!),
                child: Text('Ver en Polygonscan', style: TextStyle(fontSize: 12, color: Colors.blue[700])),
              ),
          ],
          if (timeline != null && timeline.txHash != null)
            InkWell(
              onTap: () => _copyTxHash(context, timeline.txHash!),
              child: Text('TxHash: ${timeline.txHash}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
            ),
          const SizedBox(height: 24),
          Expanded(
            child: timeline == null 
              ? const Center(child: CircularProgressIndicator())
              : () {
                  final status = timeline.currentStatus.toUpperCase();
                  int level = 0;
                  if (status == 'PENDING') level = 1;
                  if (status == 'DEPOSIT_CONFIRMED') level = 2;
                  if (status == 'IN_BLOCKCHAIN') level = 4;
                  if (status == 'COMPLETED') level = 6;
                  if (status == 'FAILED') level = -1;

                  final nodes = [
                    {
                      'label': 'Firma Criptográfica Local',
                      'detail': 'Wallet de Sagiro firma la orden con llave privada',
                      'status': level > 1 ? 'completed' : (level == 1 ? 'in_progress' : (level == -1 ? 'failed' : 'pending')),
                    },
                    {
                      'label': 'Difusión a Nodo RPC',
                      'detail': 'Enviando transacción a Alchemy Gateway (IP: 104.18.23.111)',
                      'status': level > 2 ? 'completed' : (level == 2 ? 'in_progress' : 'pending'),
                    },
                    {
                      'label': 'Mempool Pública',
                      'detail': 'Transacción en cola de red P2P (Polygon Amoy)',
                      'status': level > 3 ? 'completed' : (level == 3 ? 'in_progress' : 'pending'),
                    },
                    {
                      'label': 'Ejecución por Nodo Validador',
                      'detail': 'Validador #${timeline.txHash != null && timeline.txHash!.length > 6 ? timeline.txHash!.substring(2, 6) : "0x4"} (IP: 54.12.${timeline.txHash != null && timeline.txHash!.length > 6 ? timeline.txHash!.codeUnitAt(2) % 255 : 44}.${timeline.txHash != null && timeline.txHash!.length > 6 ? timeline.txHash!.codeUnitAt(3) % 255 : 12})',
                      'status': level > 4 ? 'completed' : (level == 4 ? 'in_progress' : 'pending'),
                    },
                    {
                      'label': 'Confirmación Descentralizada',
                      'detail': 'Bloque minado inmutablemente en la blockchain',
                      'status': level > 5 ? 'completed' : (level == 5 ? 'in_progress' : 'pending'),
                    },
                  ];

                  return ListView.builder(
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final nodeStatus = node['status'] as String;
                      
                      Color statusColor = Colors.grey;
                      IconData statusIcon = LucideIcons.circle;
                      
                      if (nodeStatus == 'completed') {
                        statusColor = Colors.green;
                        statusIcon = LucideIcons.checkCircle2;
                      } else if (nodeStatus == 'in_progress') {
                        statusColor = Colors.orange;
                        statusIcon = LucideIcons.loader;
                      } else if (nodeStatus == 'failed') {
                        statusColor = Colors.red;
                        statusIcon = LucideIcons.xCircle;
                      }

                      return ListTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Text(node['label'] as String, style: TextStyle(fontWeight: nodeStatus == 'completed' || nodeStatus == 'in_progress' ? FontWeight.bold : FontWeight.normal)),
                        subtitle: Text(node['detail'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        trailing: nodeStatus == 'in_progress' ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                      );
                    },
                  );
                }(),
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

  void _copyTxHash(BuildContext context, String txHash) {
    Clipboard.setData(ClipboardData(text: txHash));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TxHash copiado. Explorer: amoy.polygonscan.com/tx/$txHash')),
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
