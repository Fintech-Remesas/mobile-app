import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/bank_account.dart';
import '../bloc/bank_account_bloc.dart';

class BankAccountsPage extends StatefulWidget {
  const BankAccountsPage({super.key});

  @override
  State<BankAccountsPage> createState() => _BankAccountsPageState();
}

class _BankAccountsPageState extends State<BankAccountsPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _aliasController = TextEditingController();
  String _accountType = 'SAVINGS';
  String _currency = 'PEN';
  String _country = 'PE';
  bool _showForm = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _bankNameController.clear();
    _accountNumberController.clear();
    _aliasController.clear();
    setState(() {
      _accountType = 'SAVINGS';
      _currency = 'PEN';
      _country = 'PE';
      _showForm = false;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BankAccountBloc>().add(
          AddBankAccountRequested(
            bankName: _bankNameController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            accountType: _accountType,
            currency: _currency,
            country: _country,
            alias: _aliasController.text.trim().isEmpty
                ? null
                : _aliasController.text.trim(),
          ),
        );
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas bancarias')),
      body: BlocConsumer<BankAccountBloc, BankAccountState>(
        listener: (context, state) {
          if (state is BankAccountLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
          if (state is BankAccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BankAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = switch (state) {
            BankAccountLoaded(:final accounts) => accounts,
            BankAccountSubmitting(:final accounts) => accounts,
            BankAccountError(:final accounts) => accounts,
            _ => <BankAccount>[],
          };
          final isSubmitting = state is BankAccountSubmitting;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Agrega tu cuenta de origen para realizar remesas (Paso A-6).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              if (_showForm) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _bankNameController,
                        decoration: const InputDecoration(labelText: 'Banco'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _accountNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número de cuenta',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _accountType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de cuenta',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'SAVINGS',
                            child: Text('Ahorros'),
                          ),
                          DropdownMenuItem(
                            value: 'CHECKING',
                            child: Text('Corriente'),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? null
                            : (v) => setState(() => _accountType = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _currency,
                        decoration: const InputDecoration(labelText: 'Moneda'),
                        onChanged: (v) => _currency = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _country,
                        decoration: const InputDecoration(labelText: 'País'),
                        onChanged: (v) => _country = v,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _aliasController,
                        decoration: const InputDecoration(
                          labelText: 'Alias (opcional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting ? null : _resetForm,
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submit,
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => setState(() => _showForm = true),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar cuenta'),
                  ),
                ),
              const SizedBox(height: 8),
              if (accounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No tienes cuentas registradas')),
                )
              else
                ...accounts.map(
                  (account) => _BankAccountTile(
                    account: account,
                    onDelete: isSubmitting
                        ? null
                        : () => context.read<BankAccountBloc>().add(
                              DeleteBankAccountRequested(account.id),
                            ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BankAccountTile extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onDelete;

  const _BankAccountTile({required this.account, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(account.displayName),
        subtitle: Text(
          '${account.bankName} · ****${account.last4} · ${account.currency}',
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
