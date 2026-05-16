import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KYCScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Upload your ID to continue'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/kyc-pending'),
              child: const Text('Upload Document'),
            ),
          ],
        ),
      ),
    );
  }
}

class KYCPendingScreen extends StatelessWidget {
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
              child: const Text('Simulate Approval'),
            ),
          ],
        ),
      ),
    );
  }
}

class KYCApprovedScreen extends StatelessWidget {
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

class KYCRejectedScreen extends StatelessWidget {
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
