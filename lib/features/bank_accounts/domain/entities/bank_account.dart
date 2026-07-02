import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final String id;
  final String bankName;
  final String? accountNumber;
  final String last4;
  final String accountType;
  final String currency;
  final String country;
  final String? alias;
  final bool isPrimary;

  const BankAccount({
    required this.id,
    required this.bankName,
    this.accountNumber,
    required this.last4,
    required this.accountType,
    required this.currency,
    required this.country,
    this.alias,
    this.isPrimary = false,
  });

  bool get isCryptoWallet =>
      bankName.toLowerCase().contains('wallet') ||
      currency == 'USDC' ||
      (accountNumber?.startsWith('0x') ?? false);

  String get displayName => alias?.isNotEmpty == true ? alias! : bankName;

  @override
  List<Object?> get props => [
        id,
        bankName,
        accountNumber,
        last4,
        accountType,
        currency,
        country,
        alias,
        isPrimary,
      ];
}
