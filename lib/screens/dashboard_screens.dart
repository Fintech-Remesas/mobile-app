import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => context.push('/notifications'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Balance', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('\$4,250.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/send'),
                    icon: const Icon(LucideIcons.send),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/receive'),
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Receive'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(LucideIcons.arrowUpRight)),
              title: const Text('To Maria Garcia'),
              subtitle: const Text('Today, 10:30 AM'),
              trailing: const Text('-\$150.00', style: TextStyle(color: Colors.red)),
              onTap: () => context.push('/transaction/1'),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Icon(index % 2 == 0 ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft)),
            title: Text(index % 2 == 0 ? 'Sent Money' : 'Received Money'),
            subtitle: Text('Oct ${10 - index}, 2023'),
            trailing: Text(index % 2 == 0 ? '-\$50.00' : '+\$120.00',
                style: TextStyle(color: index % 2 == 0 ? Colors.red : Colors.green)),
            onTap: () => context.push('/transaction/$index'),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const CircleAvatar(radius: 40, child: Icon(LucideIcons.user, size: 40)),
          const SizedBox(height: 16),
          const Center(child: Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const Center(child: Text('john.doe@example.com')),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(LucideIcons.shield),
            title: const Text('Security'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/security'),
          ),
          ListTile(
            leading: const Icon(LucideIcons.activity),
            title: const Text('Limits'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/limits'),
          ),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}
