import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/bank_accounts_list_bloc.dart';

class BankAccountsPage extends StatefulWidget {
  const BankAccountsPage({super.key});

  @override
  State<BankAccountsPage> createState() => _BankAccountsPageState();
}

class _BankAccountsPageState extends State<BankAccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BankAccountsListBloc>().add(LoadBankAccounts());
  }

  String _getDomainForBank(String bankName) {
    final nameLower = bankName.toLowerCase();
    if (nameLower.contains('bcp') || nameLower.contains('crédito')) return 'viabcp.com';
    if (nameLower.contains('bbva')) return 'bbva.pe';
    if (nameLower.contains('interbank')) return 'interbank.pe';
    if (nameLower.contains('scotiabank')) return 'scotiabank.com.pe';
    if (nameLower.contains('banbif')) return 'banbif.com.pe';
    if (nameLower.contains('pichincha')) return 'pichincha.pe';
    if (nameLower.contains('nación')) return 'bn.com.pe';
    return ''; // Sin logo
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BankAccountsListBloc, BankAccountsListState>(
      listener: (context, state) {
        if (state is BankAccountDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta bancaria eliminada')),
          );
        } else if (state is BankAccountDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgMain,
        appBar: AppBar(
          backgroundColor: AppTheme.bgMain,
          title: Text('Mis Cuentas', style: GoogleFonts.plusJakartaSans()),
        ),
        body: BlocBuilder<BankAccountsListBloc, BankAccountsListState>(
          builder: (context, state) {
            if (state is BankAccountsListLoading || state is BankAccountsListInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BankAccountsListFailure) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            } else if (state is BankAccountsListLoaded) {
              final accounts = state.accounts;

              if (accounts.isEmpty) {
                return Center(
                  child: Text('No tienes cuentas registradas', style: GoogleFonts.inter(color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final domain = _getDomainForBank(account.bankName);

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: domain.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                'https://logo.clearbit.com/$domain',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.account_balance, size: 32, color: Colors.grey),
                              ),
                            )
                          : const Icon(Icons.account_balance, size: 32, color: Colors.grey),
                      title: Text(
                        account.bankName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('•••• ${account.last4}\n${account.accountType}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar Cuenta'),
                              content: const Text('¿Estás seguro de que deseas eliminar esta cuenta?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<BankAccountsListBloc>().add(DeleteBankAccountRequested(account.id));
                                  },
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await context.push('/add-bank-account');
                  if (context.mounted) {
                    context.read<BankAccountsListBloc>().add(LoadBankAccounts());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Agregar nueva cuenta'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
