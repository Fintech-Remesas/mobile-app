import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/localization/app_localizations.dart';
import '../bloc/profile_bloc.dart';
import '../../../kyc/presentation/bloc/kyc_bloc.dart';
import '../../../kyc/domain/entities/kyc_status.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('profile_title')),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.settings),
              onPressed: () => context.push('/general-settings'),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            if (state is ProfileLoaded) {
              return BlocBuilder<KycBloc, KycState>(
                builder: (context, kycState) {
                  final isKycApproved = kycState is KycStatusLoaded &&
                      kycState.status == KycStatus.approved;
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(LucideIcons.user, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          state.profile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(child: Text(state.profile.email)),
                      const SizedBox(height: 32),
                      ListTile(
                        leading: Icon(
                          LucideIcons.userCheck,
                          color: isKycApproved ? Colors.green : Colors.orange,
                        ),
                        title: Text(loc.translate('verify_identity')),
                        subtitle: Text(
                          isKycApproved ? loc.translate('completed') : 'Requerido para operar',
                          style: TextStyle(
                            color: isKycApproved ? Colors.green : Colors.orange,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (!isKycApproved) {
                            context.push('/kyc-start');
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.landmark),
                        title: Text(loc.translate('bank_accounts')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/bank-accounts');
                        },
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.creditCard),
                        title: Text(loc.translate('cards')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/cards');
                        },
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.shield),
                        title: Text(loc.translate('security')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/security'),
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.activity),
                        title: Text(loc.translate('limits')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/limits'),
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.settings),
                        title: Text(loc.translate('general_settings')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/general-settings'),
                      ),
                      ListTile(
                        leading: const Icon(LucideIcons.logOut, color: Colors.red),
                        title: Text(loc.translate('log_out'), style: const TextStyle(color: Colors.red)),
                        onTap: () => context.read<ProfileBloc>().add(const LogoutRequested()),
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
