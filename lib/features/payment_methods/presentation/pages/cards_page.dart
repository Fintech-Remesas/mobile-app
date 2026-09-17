import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/app_theme.dart';
import '../bloc/cards_list_bloc.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CardsListBloc>().add(LoadCards());
  }

  String _getDomainForBrand(String brand) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return 'visa.com';
      case 'MASTERCARD':
        return 'mastercard.com';
      case 'AMEX':
        return 'americanexpress.com';
      default:
        return 'visa.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CardsListBloc, CardsListState>(
      listener: (context, state) {
        if (state is CardDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarjeta eliminada')),
          );
        } else if (state is CardDeleteFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mis Tarjetas', style: GoogleFonts.plusJakartaSans()),
        ),
        body: BlocBuilder<CardsListBloc, CardsListState>(
          builder: (context, state) {
            if (state is CardsListLoading || state is CardsListInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CardsListFailure) {
              return Center(
                child: Text(state.message, style: const TextStyle(color: Colors.red)),
              );
            } else if (state is CardsListLoaded) {
              final cards = state.cards;

              if (cards.isEmpty) {
                return Center(
                  child: Text('No tienes tarjetas registradas', style: GoogleFonts.inter(color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  final domain = _getDomainForBrand(card.cardBrand);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'https://logo.clearbit.com/$domain',
                          width: 48,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.credit_card, size: 32, color: Colors.grey),
                        ),
                      ),
                      title: Text(
                        '•••• ${card.last4}',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(card.cardholderName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar Tarjeta'),
                              content: const Text('¿Estás seguro de que deseas eliminar esta tarjeta?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.read<CardsListBloc>().add(DeleteCardRequested(card.id));
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
                  await context.push('/add-card');
                  // Al volver de la pantalla de agregar, recargamos la lista
                  if (context.mounted) {
                    context.read<CardsListBloc>().add(LoadCards());
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Agregar nueva tarjeta'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
