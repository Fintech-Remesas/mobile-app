import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/wallet_summary.dart';

class BalanceCard extends StatelessWidget {
  final WalletSummary wallet;

  const BalanceCard({super.key, required this.wallet});

  String _formatBalance(double balance) {
    final parts = balance.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$whole.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatBalance(wallet.balance);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Available Balance',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            formatted,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
