import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }
          if (state is SecurityLoaded) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SwitchListTile(
                  title: const Text('Biometric Authentication'),
                  value: state.biometricEnabled,
                  onChanged: (val) => context
                      .read<SettingsBloc>()
                      .add(ToggleBiometricRequested(val)),
                ),
                const ListTile(
                  title: Text('Change Password'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                  title: Text('Active Sessions'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
