import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/add_bank_account_bloc.dart';

class AddBankAccountPage extends StatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  State<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _customBankCtrl = TextEditingController();

  String _selectedAccountType = 'SAVINGS';
  String _selectedCurrency = 'USD';
  String _selectedCountry = 'PE';
  
  String? _selectedBank;
  
  final List<Map<String, String>> _banks = [
    {'name': 'Banco de Crédito del Perú (BCP)', 'domain': 'viabcp.com'},
    {'name': 'BBVA', 'domain': 'bbva.pe'},
    {'name': 'Interbank', 'domain': 'interbank.pe'},
    {'name': 'Scotiabank', 'domain': 'scotiabank.com.pe'},
    {'name': 'BanBif', 'domain': 'banbif.com.pe'},
    {'name': 'Banco Pichincha', 'domain': 'pichincha.pe'},
    {'name': 'Banco de la Nación', 'domain': 'bn.com.pe'},
    {'name': 'Otro', 'domain': ''},
  ];

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _aliasCtrl.dispose();
    _customBankCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    String finalBankName = _selectedBank == 'Otro' 
        ? _customBankCtrl.text.trim() 
        : _selectedBank ?? '';

    if (finalBankName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un banco')),
      );
      return;
    }

    context.read<AddBankAccountBloc>().add(
      AddBankAccountSubmitted(
        bankName: finalBankName,
        accountNumber: _accountNumberCtrl.text.replaceAll(' ', ''),
        accountType: _selectedAccountType,
        currency: _selectedCurrency,
        country: _selectedCountry,
        alias: _aliasCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddBankAccountBloc, AddBankAccountState>(
      listener: (context, state) {
        if (state is AddBankAccountSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta añadida exitosamente')),
          );
          context.pop();
        } else if (state is AddBankAccountFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgMain,
        appBar: AppBar(
          backgroundColor: AppTheme.bgMain,
          title: Text('Agregar Cuenta', style: GoogleFonts.plusJakartaSans()),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBank,
                  hint: const Text('Nombre del banco'),
                  decoration: const InputDecoration(labelText: 'Banco'),
                  items: _banks.map((bank) {
                    final domain = bank['domain']!;
                    return DropdownMenuItem<String>(
                      value: bank['name'],
                      child: Row(
                        children: [
                          if (domain.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                'https://logo.clearbit.com/$domain',
                                width: 24,
                                height: 24,
                                errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 24, color: Colors.grey),
                              ),
                            )
                          else
                            const Icon(Icons.account_balance, size: 24, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(bank['name']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedBank = v),
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                if (_selectedBank == 'Otro') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customBankCtrl,
                    decoration: const InputDecoration(labelText: 'Ingresa el nombre del banco'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNumberCtrl,
                  decoration: const InputDecoration(labelText: 'Número de cuenta'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAccountType,
                  decoration: const InputDecoration(labelText: 'Tipo de cuenta'),
                  items: const [
                    DropdownMenuItem(value: 'SAVINGS', child: Text('Ahorros')),
                    DropdownMenuItem(value: 'CHECKING', child: Text('Corriente')),
                  ],
                  onChanged: (v) => setState(() => _selectedAccountType = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: const InputDecoration(labelText: 'Moneda'),
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'PEN', child: Text('PEN')),
                        ],
                        onChanged: (v) => setState(() => _selectedCurrency = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(labelText: 'País'),
                        items: const [
                          DropdownMenuItem(value: 'PE', child: Text('Perú')),
                          DropdownMenuItem(value: 'US', child: Text('Estados Unidos')),
                        ],
                        onChanged: (v) => setState(() => _selectedCountry = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aliasCtrl,
                  decoration: const InputDecoration(labelText: 'Alias (Opcional)'),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AddBankAccountBloc, AddBankAccountState>(
                  builder: (context, state) {
                    final isLoading = state is AddBankAccountLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Agregar Cuenta'),
                      ),
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
