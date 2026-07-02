import '../../domain/entities/bank_account.dart';

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required super.id,
    required super.bankName,
    super.accountNumber,
    required super.last4,
    required super.accountType,
    required super.currency,
    required super.country,
    super.alias,
    super.isPrimary,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String?,
      last4: json['last4'] as String? ?? '****',
      accountType: json['accountType'] as String? ?? 'SAVINGS',
      currency: json['currency'] as String? ?? 'USD',
      country: json['country'] as String? ?? 'PE',
      alias: json['alias'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}
