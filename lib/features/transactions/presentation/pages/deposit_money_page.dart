import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../payment_methods/domain/entities/payment_card.dart';
import '../../../payment_methods/presentation/bloc/cards_list_bloc.dart';
import '../bloc/deposit_bloc.dart';

class DepositMoneyPage extends StatefulWidget {
  const DepositMoneyPage({super.key});

  @override
  State<DepositMoneyPage> createState() => _DepositMoneyPageState();
}

class _DepositMoneyPageState extends State<DepositMoneyPage> {
  final _amountController = TextEditingController();
  String? _selectedCardId;

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
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a card')),
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

    context.read<DepositBloc>().add(SubmitDeposit(
      amount: amount,
      currency: 'USD',
      cardId: _selectedCardId!,
      description: 'Deposit from card',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DepositBloc>()),
        BlocProvider(create: (_) => sl<CardsListBloc>()..add(LoadCards())),
      ],
      child: BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Transacción exitosa'),
                content: const Text('Tu recarga se ha procesado correctamente.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      context.read<HomeBloc>().add(const RefreshHome());
                      context.pop(); // Close page
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          } else if (state is DepositFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Deposit Money')),
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
                BlocBuilder<CardsListBloc, CardsListState>(
                  builder: (context, state) {
                    if (state is CardsListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CardsListLoaded) {
                      if (state.cards.isEmpty) {
                        return const Text('No cards available. Please add a card first.');
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedCardId,
                        hint: const Text('Select a card'),
                        isExpanded: true,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: state.cards.map((PaymentCard card) {
                          return DropdownMenuItem<String>(
                            value: card.id,
                            child: Text('${card.cardBrand} ending in ${card.last4}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCardId = value;
                          });
                        },
                      );
                    } else if (state is CardsListFailure) {
                      return Text('Error loading cards: ${state.message}');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const Spacer(),
                BlocBuilder<DepositBloc, DepositState>(
                  builder: (context, state) {
                    final isLoading = state is DepositLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Deposit'),
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
