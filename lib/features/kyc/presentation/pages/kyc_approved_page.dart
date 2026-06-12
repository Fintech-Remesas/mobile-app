import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KycApprovedPage extends StatelessWidget {
  const KycApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Approved')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Successfully verified!'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Continue to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
