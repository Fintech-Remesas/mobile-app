import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/home_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

class QuickActionsRow extends StatelessWidget {
  final bool enabled;

  const QuickActionsRow({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  final allowTestRecharge = profileState is ProfileLoaded && profileState.profile.allowTestRecharge;
                  return ElevatedButton.icon(
                    onPressed: enabled
                        ? () {
                            if (!allowTestRecharge) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tu cuenta no tiene permisos para recargas ficticias.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              context.push('/deposit');
                            }
                          }
                        : null,
                    icon: const Icon(LucideIcons.arrowUpCircle),
                    label: const Text('Deposit'),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? () => context.push('/withdraw') : null,
                icon: const Icon(LucideIcons.arrowDownCircle),
                label: const Text('Withdraw'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: enabled ? () => context.push('/transaction') : null,
          icon: const Icon(LucideIcons.arrowRightLeft),
          label: const Text('Transferir'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blue[700], // distinct color
            foregroundColor: Colors.white,
          ),
        ),

      ],
    );
  }
}
