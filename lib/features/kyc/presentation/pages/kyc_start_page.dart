import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/kyc_bloc.dart';

class KycStartPage extends StatelessWidget {
  const KycStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          context.go('/kyc-approved');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Identity Verification')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Upload your ID to continue'),
              const SizedBox(height: 32),
              BlocBuilder<KycBloc, KycState>(
                builder: (context, state) {
                  final isLoading = state is KycLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<KycBloc>().add(const SubmitKycRequested()),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Upload Document'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
