import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/crypto_deposit/crypto_deposit_bloc.dart';
import '../bloc/crypto_deposit/crypto_deposit_event.dart';
import '../bloc/crypto_deposit/crypto_deposit_state.dart';

class CryptoDepositPage extends StatefulWidget {
  const CryptoDepositPage({super.key});

  @override
  State<CryptoDepositPage> createState() => _CryptoDepositPageState();
}

class _CryptoDepositPageState extends State<CryptoDepositPage> {
  final _amountController = TextEditingController();
  final _txHashController = TextEditingController();
  String _selectedCrypto = 'bitcoin';

  final List<Map<String, String>> _cryptos = [
    {'id': 'bitcoin', 'name': 'Bitcoin (BTC)'},
    {'id': 'ethereum', 'name': 'Ethereum (ETH)'},
    {'id': 'solana', 'name': 'Solana (SOL)'},
    {'id': 'litecoin', 'name': 'Litecoin (LTC)'},
  ];

  String _getFakeAddress(String cryptoId) {
    if (cryptoId == 'bitcoin') return 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
    if (cryptoId == 'ethereum') return '0x71C7656EC7ab88b098defB751B7401B5f6d8976F';
    if (cryptoId == 'solana') return 'HN7cABqLq46Es1jh92dQQisAq662SmxELLLsHHe4YWrH';
    if (cryptoId == 'litecoin') return 'ltc1q4jd849cwjw7c7s54p5yxgc3gxtm76k9k0zly2q';
    return '0x...';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _txHashController.dispose();
    super.dispose();
  }

  void _fetchQuote(BuildContext context) {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un monto válido.')),
      );
      return;
    }

    context.read<CryptoDepositBloc>().add(
          FetchCryptoQuote(
            cryptoId: _selectedCrypto,
            cryptoAmount: amount,
          ),
        );
  }

  void _submitDeposit(BuildContext context, CryptoDepositQuoteReady quote) {
    if (_txHashController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el código/hash de transacción como prueba.')),
      );
      return;
    }

    context.read<CryptoDepositBloc>().add(
          SubmitCryptoDeposit(
            cryptoId: quote.cryptoId,
            cryptoAmount: quote.cryptoAmount,
            usdEquivalent: quote.usdEquivalent,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CryptoDepositBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recargar con Crypto'),
        ),
        body: BlocConsumer<CryptoDepositBloc, CryptoDepositState>(
          listener: (context, state) {
            if (state is CryptoDepositFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.redAccent),
              );
            } else if (state is CryptoDepositSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Recarga exitosa! Tu balance ha sido actualizado.'), backgroundColor: Colors.green),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(LucideIcons.bitcoin, size: 64, color: Colors.purpleAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Simula una recarga usando Criptomonedas. El monto será convertido a USDC en tiempo real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  // Formulario de ingreso
                  DropdownButtonFormField<String>(
                    value: _selectedCrypto,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona la Criptomoneda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.coins),
                    ),
                    items: _cryptos.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'],
                        child: Text(c['name']!),
                      );
                    }).toList(),
                    onChanged: state is CryptoDepositLoadingQuote || state is CryptoDepositSubmitting
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() => _selectedCrypto = val);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      hintText: 'Ej. 0.05',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(LucideIcons.penTool),
                    ),
                    enabled: state is! CryptoDepositLoadingQuote && state is! CryptoDepositSubmitting,
                  ),
                  const SizedBox(height: 24),
                  
                  if (state is CryptoDepositInitial || state is CryptoDepositFailure || state is CryptoDepositQuoteExpired)
                    ElevatedButton(
                      onPressed: () => _fetchQuote(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(state is CryptoDepositQuoteExpired ? 'Volver a Cotizar' : 'Cotizar'),
                    ),

                  if (state is CryptoDepositLoadingQuote)
                    const Center(child: CircularProgressIndicator()),

                  if (state is CryptoDepositQuoteReady) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purpleAccent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Envía los fondos a esta dirección:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _getFakeAddress(state.cryptoId),
                            style: const TextStyle(fontFamily: 'monospace', color: Colors.purple, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _txHashController,
                            decoration: const InputDecoration(
                              labelText: 'Código / Hash de Transacción',
                              hintText: 'Pega el TxHash aquí',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(LucideIcons.hash),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Equivalencia Estimada',
                                  style: TextStyle(fontSize: 14, color: Colors.purple[700]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${state.usdEquivalent.toStringAsFixed(2)} USDC',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.clock, size: 16, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Expira en ${state.secondsRemaining}s',
                                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _submitDeposit(context, state),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aceptar y Recargar'),
                    ),
                  ],

                  if (state is CryptoDepositQuoteExpired) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'La cotización ha expirado. Por favor, vuelve a cotizar para obtener el precio actualizado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],

                  if (state is CryptoDepositSubmitting)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Procesando recarga...'),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
