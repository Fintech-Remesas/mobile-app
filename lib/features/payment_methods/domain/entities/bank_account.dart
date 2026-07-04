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
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
