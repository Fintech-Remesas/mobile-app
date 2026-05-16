import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SendMoneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Recipient'),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: 'Search by name or phone')),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Contact $index'),
                    subtitle: const Text('+1 234 567 8900'),
                    onTap: () {
                      // Simulating selection and sending
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected. Implement Send flow.')));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiveMoneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Money')),
      body: const Center(
        child: Text('QR Code or Link to receive money'),
      ),
    );
  }
}

class TransactionDetailScreen extends StatelessWidget {
  final String id;
  const TransactionDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('-\$150.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ListTile(
              title: const Text('Status'),
              trailing: const Text('Completed', style: TextStyle(color: Colors.green)),
            ),
            ListTile(
              title: const Text('To'),
              trailing: const Text('Maria Garcia'),
            ),
            ListTile(
              title: const Text('Transaction ID'),
              trailing: Text('TRX-$id'),
            ),
          ],
        ),
      ),
    );
  }
}
