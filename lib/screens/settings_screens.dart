import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notification $index'),
            subtitle: const Text('This is a dummy notification description.'),
          );
        },
      ),
    );
  }
}

class LimitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Limits')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: 0.4, minHeight: 12, borderRadius: BorderRadius.circular(6)),
            const SizedBox(height: 8),
            const Text('\$400 / \$1,000 used'),
            const SizedBox(height: 32),
            const Text('Monthly Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: 0.1, minHeight: 12, borderRadius: BorderRadius.circular(6)),
            const SizedBox(height: 8),
            const Text('\$1,000 / \$10,000 used'),
          ],
        ),
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            value: true,
            onChanged: (val) {},
          ),
          const ListTile(
            title: Text('Change Password'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Active Sessions'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
