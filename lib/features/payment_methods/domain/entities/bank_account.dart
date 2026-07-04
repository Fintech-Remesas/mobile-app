class BankAccount {
  final String id;
  final String bankName;
  final String last4;
  final String accountType;
  final String currency;
  final String country;
  final String alias;
  final bool isPrimary;
  final DateTime createdAt;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.accountType,
    required this.currency,
    required this.country,
    required this.alias,
    required this.isPrimary,
    required this.createdAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      last4: json['last4'] ?? '',
      accountType: json['accountType'] ?? '',
      currency: json['currency'] ?? '',
      country: json['country'] ?? '',
      alias: json['alias'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is List && date.length >= 6) {
      return DateTime(date[0], date[1], date[2], date[3], date[4], date[5]);
    }
    return DateTime.now();
  }
}
