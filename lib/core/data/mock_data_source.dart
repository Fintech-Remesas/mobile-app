class MockDataSource {
  static const double walletBalance = 4250.00;
  static const String walletCurrency = 'USD';

  static const profileName = 'John Doe';
  static const profileEmail = 'john.doe@example.com';

  static const List<Map<String, dynamic>> recentTransactions = [
    {
      'id': '1',
      'title': 'To Maria Garcia',
      'subtitle': 'Today, 10:30 AM',
      'amount': -150.00,
      'isOutgoing': true,
    },
    {
      'id': '2',
      'title': 'From Carlos Ruiz',
      'subtitle': 'Yesterday, 4:15 PM',
      'amount': 320.00,
      'isOutgoing': false,
    },
    {
      'id': '3',
      'title': 'To Ana López',
      'subtitle': 'Jun 10, 9:00 AM',
      'amount': -75.50,
      'isOutgoing': true,
    },
  ];

  static List<Map<String, dynamic>> get historyTransactions => List.generate(
        10,
        (index) => {
          'id': '$index',
          'title': index % 2 == 0 ? 'Sent Money' : 'Received Money',
          'subtitle': 'Oct ${10 - index}, 2023',
          'amount': index % 2 == 0 ? -50.00 : 120.00,
          'isOutgoing': index % 2 == 0,
        },
      );

  static List<Map<String, String>> get contacts => List.generate(
        5,
        (index) => {
          'id': '$index',
          'name': 'Contact $index',
          'phone': '+1 234 567 8900',
        },
      );

  static List<Map<String, String>> get notifications => List.generate(
        3,
        (index) => {
          'id': '$index',
          'title': 'Notification $index',
          'body': 'This is a dummy notification description.',
        },
      );

  static const Map<String, dynamic> limits = {
    'dailyUsed': 400.0,
    'dailyTotal': 1000.0,
    'monthlyUsed': 1000.0,
    'monthlyTotal': 10000.0,
  };

  static const Map<String, dynamic> transactionDetail = {
    'id': '1',
    'amount': -150.00,
    'status': 'Completed',
    'recipient': 'Maria Garcia',
    'transactionHash':
        '0x7f3a9b2c1d4e5f6a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
    'network': 'amoyTestnet',
    'blockNumber': 12847563,
    'confirmationStatus': 'confirmed',
    'blockTimestamp': '2026-06-12T14:32:00',
  };

  Future<void> simulateDelay() => Future.delayed(const Duration(milliseconds: 400));
}
