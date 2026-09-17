import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/add_card_bloc.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryMonthCtrl = TextEditingController();
  final _expiryYearCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();

  String _selectedBrand = 'VISA';
  String _selectedType = 'CREDIT';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryMonthCtrl.dispose();
    _expiryYearCtrl.dispose();
    _aliasCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<AddCardBloc>().add(
      AddCardSubmitted(
        cardholderName: _nameCtrl.text.trim(),
        cardNumber: _numberCtrl.text.replaceAll(' ', ''),
        expiryMonth: int.parse(_expiryMonthCtrl.text),
        expiryYear: int.parse(_expiryYearCtrl.text),
        cardBrand: _selectedBrand,
        cardType: _selectedType,
        alias: _aliasCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCardBloc, AddCardState>(
      listener: (context, state) {
        if (state is AddCardSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta añadida exitosamente')),
          );
          context.pop();
        } else if (state is AddCardFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Agregar Tarjeta', style: GoogleFonts.plusJakartaSans()),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Titular de la tarjeta'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Número de tarjeta'),
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 13) return 'Debe tener al menos 13 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryMonthCtrl,
                        decoration: const InputDecoration(labelText: 'Mes (MM)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final m = int.tryParse(v);
                          if (m == null || m < 1 || m > 12) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _expiryYearCtrl,
                        decoration: const InputDecoration(labelText: 'Año (YYYY)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final y = int.tryParse(v);
                          if (y == null || y < 2024) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  items: [
                    {'value': 'VISA', 'label': 'Visa', 'domain': 'visa.com'},
                    {'value': 'MASTERCARD', 'label': 'Mastercard', 'domain': 'mastercard.com'},
                    {'value': 'AMEX', 'label': 'American Express', 'domain': 'americanexpress.com'},
                  ].map((brand) {
                    return DropdownMenuItem<String>(
                      value: brand['value'],
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              'https://logo.clearbit.com/${brand['domain']}',
                              width: 32,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.credit_card, size: 24, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(brand['label']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedBrand = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: const [
                    DropdownMenuItem(value: 'CREDIT', child: Text('Crédito')),
                    DropdownMenuItem(value: 'DEBIT', child: Text('Débito')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aliasCtrl,
                  decoration: const InputDecoration(labelText: 'Alias (Opcional)'),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AddCardBloc, AddCardState>(
                  builder: (context, state) {
                    final isLoading = state is AddCardLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Agregar Tarjeta'),
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
