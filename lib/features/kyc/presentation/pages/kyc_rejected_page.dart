import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KycRejectedPage extends StatelessWidget {
  const KycRejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Rejected')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Your documents were rejected.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/kyc-start'),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
