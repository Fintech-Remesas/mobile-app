import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_theme.dart';
import '../../../bank_accounts/domain/entities/bank_account.dart';
import '../../../bank_accounts/presentation/bloc/bank_account_bloc.dart';

class ReceiveMoneyPage extends StatefulWidget {
  const ReceiveMoneyPage({super.key});

  @override
  State<ReceiveMoneyPage> createState() => _ReceiveMoneyPageState();
}

class _ReceiveMoneyPageState extends State<ReceiveMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final _walletController = TextEditingController();
  final _aliasController = TextEditingController();
  bool _showForm = false;
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    context.read<BankAccountBloc>().add(const LoadBankAccounts());
  }

  @override
  void dispose() {
    _walletController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _submitWallet() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BankAccountBloc>().add(
          AddBankAccountRequested(
            bankName: 'Polygon Wallet',
            accountNumber: _walletController.text.trim(),
            accountType: 'SAVINGS',
            currency: 'USDC',
            country: 'US',
            alias: _aliasController.text.trim().isEmpty
                ? 'Wallet Polygon AMOY'
                : _aliasController.text.trim(),
          ),
        );
    _walletController.clear();
    _aliasController.clear();
    setState(() => _showForm = false);
  }

  void _copyText(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado al portapapeles')),
    );
  }

  void _copyShareBundle(BankAccount wallet) {
    final address = wallet.accountNumber ?? '';
    final text = 'Datos para enviarme dinero en Sagiro:\n'
        'ID cuenta: ${wallet.id}\n'
        'Wallet: $address';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos para compartir copiados al portapapeles'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recibir dinero')),
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

          final allAccounts = switch (state) {
            BankAccountLoaded(:final accounts) => accounts,
            BankAccountSubmitting(:final accounts) => accounts,
            BankAccountError(:final accounts) => accounts,
            _ => <BankAccount>[],
          };
          final wallets =
              allAccounts.where((a) => a.isCryptoWallet).toList();
          final isSubmitting = state is BankAccountSubmitting;
          final selected = wallets.cast<BankAccount?>().firstWhere(
                (w) => w!.id == _selectedWalletId,
                orElse: () => wallets.isNotEmpty ? wallets.first : null,
              );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Registra tu wallet Polygon para recibir USDC. '
                'Comparte tu ID de cuenta y dirección wallet con quien te envíe dinero.',
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
                        controller: _walletController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección wallet (0x...)',
                          hintText: '0x91c8AE9c06dF2a431E16664e3459F157C910827F',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa la dirección';
                          }
                          if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v.trim())) {
                            return 'Dirección inválida (0x + 40 hex)';
                          }
                          return null;
                        },
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
                              onPressed: isSubmitting
                                  ? null
                                  : () => setState(() => _showForm = false),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submitWallet,
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Registrar wallet'),
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
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: const Text('Registrar wallet Polygon'),
                  ),
                ),
              if (selected != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Compartir con quien te envíe',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _ShareRow(
                        label: 'ID cuenta bancaria',
                        value: selected.id,
                        onCopy: () => _copyText('ID de cuenta', selected.id),
                      ),
                      const SizedBox(height: 8),
                      if (selected.accountNumber != null)
                        _ShareRow(
                          label: 'Dirección wallet',
                          value: selected.accountNumber!,
                          onCopy: () => _copyText(
                            'Dirección wallet',
                            selected.accountNumber!,
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _copyShareBundle(selected),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Copiar datos para compartir'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Tus wallets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              if (wallets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No tienes wallets registradas'),
                  ),
                )
              else
                ...wallets.map(
                  (wallet) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: wallet.id == selected?.id
                        ? AppTheme.surfaceLight
                        : null,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedWalletId = wallet.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    wallet.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (wallet.id == selected?.id)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryBlue,
                                    size: 20,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${wallet.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            if (wallet.accountNumber != null)
                              SelectableText(
                                wallet.accountNumber!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              )
                            else
                              Text('****${wallet.last4}'),
                          ],
                        ),
                      ),
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

class _ShareRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _ShareRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              SelectableText(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onCopy,
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copiar',
        ),
      ],
    );
  }
}
