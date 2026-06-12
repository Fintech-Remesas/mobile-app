import 'package:flutter/material.dart';

class ReceiveMoneyPage extends StatelessWidget {
  const ReceiveMoneyPage({super.key});

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
