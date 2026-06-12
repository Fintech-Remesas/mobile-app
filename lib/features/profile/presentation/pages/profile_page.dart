import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            if (state is ProfileLoaded) {
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
                    leading: const Icon(LucideIcons.shield),
                    title: const Text('Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/security'),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.activity),
                    title: const Text('Limits'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/limits'),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.logOut, color: Colors.red),
                    title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    onTap: () => context.read<ProfileBloc>().add(const LogoutRequested()),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
