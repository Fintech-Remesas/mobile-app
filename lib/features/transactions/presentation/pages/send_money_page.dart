import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/contact.dart';
import '../bloc/send_bloc.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleStateChanges(BuildContext context, SendState state) {
    if (state is SendSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Remesa enviada a ${state.contact.name}')),
      );
      context.push('/transaction/${state.remittanceId}');
    }
    if (state is SendError && state.contact != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _buildRecipientForm(BuildContext context, Contact contact, bool isSubmitting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                onPressed: isSubmitting
                    ? null
                    : () => context.read<SendBloc>().add(const ClearRecipient()),
                child: const Text('Cambiar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _amountController,
          enabled: !isSubmitting,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monto (USD)',
            hintText: '0.00',
            prefixText: '\$ ',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Destino: PEN',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : () {
                    final amount = double.tryParse(_amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ingresa un monto válido mayor a 0'),
                        ),
                      );
                      return;
                    }
                    context.read<SendBloc>().add(SubmitSend(amount));
                  },
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar dinero'),
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
        const Text('Select Recipient'),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by name or phone',
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
                    child: Text('Type at least 2 characters to search users'),
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
                child: Text('Type at least 2 characters to search users'),
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
      appBar: AppBar(title: const Text('Send Money')),
      body: BlocConsumer<SendBloc, SendState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          final showForm = state is SendRecipientSelected ||
              state is SendSubmitting ||
              (state is SendError && state.contact != null);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: showForm
                ? _buildRecipientForm(
                    context,
                    state is SendRecipientSelected
                        ? state.contact
                        : state is SendSubmitting
                            ? state.contact
                            : (state as SendError).contact!,
                    state is SendSubmitting,
                  )
                : _buildSearchSection(context, state),
          );
        },
      ),
    );
  }
}
