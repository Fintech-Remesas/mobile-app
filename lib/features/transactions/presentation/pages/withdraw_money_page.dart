import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../payment_methods/domain/entities/bank_account.dart';
import '../../../payment_methods/presentation/bloc/bank_accounts_list_bloc.dart';
import '../bloc/withdraw_bloc.dart';

class WithdrawMoneyPage extends StatefulWidget {
  const WithdrawMoneyPage({super.key});

  @override
  State<WithdrawMoneyPage> createState() => _WithdrawMoneyPageState();
}

class _WithdrawMoneyPageState extends State<WithdrawMoneyPage> {
  final _amountController = TextEditingController();
  String? _selectedBankAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_selectedBankAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than zero')),
      );
      return;
    }

    context.read<WithdrawBloc>().add(SubmitWithdraw(
      amount: amount,
      currency: 'USD',
      bankAccountId: _selectedBankAccountId!,
      description: 'Withdraw to bank account',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WithdrawBloc>()),
        BlocProvider(create: (_) => sl<BankAccountsListBloc>()..add(LoadBankAccounts())),
      ],
      child: BlocListener<WithdrawBloc, WithdrawState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Withdrawal successful!')),
            );
            context.read<HomeBloc>().add(RefreshHome());
            context.pop();
          } else if (state is WithdrawFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Withdraw Money')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<BankAccountsListBloc, BankAccountsListState>(
                  builder: (context, state) {
                    if (state is BankAccountsListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is BankAccountsListLoaded) {
                      if (state.accounts.isEmpty) {
                        return const Text('No bank accounts available. Please add one first.');
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedBankAccountId,
                        hint: const Text('Select a bank account'),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: state.accounts.map((BankAccount account) {
                          return DropdownMenuItem<String>(
                            value: account.id,
                            child: Text('${account.bankName} ending in ${account.last4}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBankAccountId = value;
                          });
                        },
                      );
                    } else if (state is BankAccountsListFailure) {
                      return Text('Error loading bank accounts: ${state.message}');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const Spacer(),
                BlocBuilder<WithdrawBloc, WithdrawState>(
                  builder: (context, state) {
                    final isLoading = state is WithdrawLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Withdraw'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
