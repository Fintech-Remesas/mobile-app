import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/polygon_node_card.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: AppTheme.accentGreen),
            const SizedBox(height: 16),
            Text(
              '-\$150.00',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                  ),
            ),
            const SizedBox(height: 32),
            const ListTile(
              title: Text('Status'),
              trailing: Text(
                'Completed',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const ListTile(
              title: Text('To'),
              trailing: Text('Maria Garcia'),
            ),
            ListTile(
              title: const Text('Transaction ID'),
              trailing: Text('TRX-$id'),
            ),
            const SizedBox(height: 24),
            PolygonNodeCard(
              transactionHash:
                  '0x7f3a9b2c1d4e5f6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
              network: PolygonNetwork.amoyTestnet,
              blockNumber: 12847563,
              status: PolygonConfirmationStatus.confirmed,
              blockTimestamp: DateTime(2026, 6, 12, 14, 32),
            ),
          ],
        ),
      ),
    );
  }
}
