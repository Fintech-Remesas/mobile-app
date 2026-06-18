import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KycPendingPage extends StatelessWidget {
  const KycPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Pending')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Reviewing documents...'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/kyc-approved'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
