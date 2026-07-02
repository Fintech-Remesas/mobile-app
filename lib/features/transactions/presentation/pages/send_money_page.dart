import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/remittance_destination.dart';
import '../bloc/send_bloc.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  final _bankAccountIdController = TextEditingController();
  final _walletAddressController = TextEditingController();
  final _noteController = TextEditingController();

  static final _walletRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _bankAccountIdController.dispose();
    _walletAddressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  RemittanceDestination? _buildDestination(Contact contact) {
    final bankAccountId = _bankAccountIdController.text.trim();
    final walletAddress = _walletAddressController.text.trim();
    final note = _noteController.text.trim();

    if (bankAccountId.isEmpty || walletAddress.isEmpty) {
      return null;
    }

    if (!_walletRegex.hasMatch(walletAddress)) {
      return null;
    }

    return RemittanceDestination(
      destinationUserId: contact.destinationUserId,
      destinationBankAccountId: bankAccountId,
      destinationWalletAddress: walletAddress,
      note: note.isEmpty ? null : note,
    );
  }

  void _handleStateChanges(BuildContext context, SendState state) {
    if (state is SendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remesa creada para ${state.contact.name}')),
      );
      context.push('/transaction/${state.remittanceId}/deposit');
    }
    if (state is SendQuoteReady && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
    if (state is SendError && state.contact != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _buildQuoteReview(
    BuildContext context,
    Contact contact,
    Quote quote,
    RemittanceDestination destination,
    bool isSubmitting,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Revisar cotización',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _ReviewRow('Destinatario', contact.name),
        _ReviewRow('Monto origen', '\$${quote.sourceAmount.toStringAsFixed(2)} ${quote.sourceCurrency}'),
        _ReviewRow('Monto destino', '${quote.destAmount.toStringAsFixed(2)} ${quote.destCurrency}'),
        if (quote.exchangeRate != null)
          _ReviewRow('Tipo de cambio', quote.exchangeRate!.toStringAsFixed(4)),
        if (quote.platformFee != null)
          _ReviewRow('Comisión', '\$${quote.platformFee!.toStringAsFixed(2)}'),
        if (quote.expiresAt != null)
          _ReviewRow(
            'Expira',
            quote.expiresAt!.toLocal().toString().substring(0, 16),
          ),
        _ReviewRow('Wallet destino', destination.destinationWalletAddress),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () => context.read<SendBloc>().add(
                      ConfirmSend(
                        contact: contact,
                        quote: quote,
                        destination: destination,
                      ),
                    ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirmar remesa'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: isSubmitting
              ? null
              : () => context.read<SendBloc>().add(SelectRecipient(contact)),
          child: const Text('Volver'),
        ),
      ],
    );
  }

  Widget _buildRecipientForm(
    BuildContext context,
    Contact contact,
    bool isBusy,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactHeader(
          contact: contact,
          onChange: isBusy
              ? null
              : () => context.read<SendBloc>().add(const ClearRecipient()),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _amountController,
          enabled: !isBusy,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monto (USD)',
            hintText: '0.00',
            prefixText: '\$ ',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Datos de recepción del destinatario',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'El receptor debe compartirte su ID de cuenta bancaria y dirección wallet '
          'desde la pantalla Recibir.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bankAccountIdController,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'ID cuenta bancaria destino *',
            hintText: 'UUID de la cuenta en IAM',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _walletAddressController,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Dirección wallet destino (0x...) *',
            hintText: '0x91c8AE9c06dF2a431E16664e3459F157C910827F',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Nota (opcional)',
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isBusy
                ? null
                : () {
                    final amount =
                        double.tryParse(_amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingresa un monto válido mayor a 0'),
                        ),
                      );
                      return;
                    }
                    final wallet = _walletAddressController.text.trim();
                    if (!_walletRegex.hasMatch(wallet)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La dirección wallet debe ser 0x seguido de 40 caracteres hex',
                          ),
                        ),
                      );
                      return;
                    }
                    final destination = _buildDestination(contact);
                    if (destination == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa el ID de cuenta y la wallet'),
                        ),
                      );
                      return;
                    }
                    context.read<SendBloc>().add(
                          RequestQuote(
                            contact: contact,
                            amount: amount,
                            destination: destination,
                          ),
                        );
                  },
            child: isBusy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Obtener cotización'),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection(BuildContext context, SendState state) {
    final isSearching = state is SendLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccionar destinatario'),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre o teléfono',
          ),
          onChanged: (value) {
            context.read<SendBloc>().add(SearchContacts(value));
          },
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Builder(
            builder: (context) {
              if (isSearching) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is SendError && state.contact == null) {
                return Center(child: Text(state.message));
              }
              if (state is SendLoaded) {
                if (state.contacts.isEmpty) {
                  return const Center(
                    child: Text('Escribe al menos 2 caracteres para buscar'),
                  );
                }
                return ListView.builder(
                  itemCount: state.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = state.contacts[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      onTap: () {
                        context.read<SendBloc>().add(SelectRecipient(contact));
                      },
                    );
                  },
                );
              }
              return const Center(
                child: Text('Escribe al menos 2 caracteres para buscar'),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar dinero')),
      body: BlocConsumer<SendBloc, SendState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state is SendQuoteReady) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: _buildQuoteReview(
                context,
                state.contact,
                state.quote,
                state.destination,
                false,
              ),
            );
          }

          if (state is SendSubmitting) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: _buildQuoteReview(
                context,
                state.contact,
                state.quote,
                state.destination,
                true,
              ),
            );
          }

          final showForm = state is SendRecipientSelected ||
              state is SendQuoting ||
              (state is SendError && state.contact != null);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: showForm
                ? _buildRecipientForm(
                    context,
                    state is SendRecipientSelected
                        ? state.contact
                        : state is SendQuoting
                            ? state.contact
                            : (state as SendError).contact!,
                    state is SendQuoting,
                  )
                : _buildSearchSection(context, state),
          );
        },
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onChange;

  const _ContactHeader({required this.contact, this.onChange});

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
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (contact.phone.isNotEmpty)
                  Text(
                    contact.phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
