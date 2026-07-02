part of 'bank_account_bloc.dart';

abstract class BankAccountEvent extends Equatable {
  const BankAccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankAccounts extends BankAccountEvent {
  const LoadBankAccounts();
}

class AddBankAccountRequested extends BankAccountEvent {
  final String bankName;
  final String accountNumber;
  final String accountType;
  final String currency;
  final String country;
  final String? alias;

  const AddBankAccountRequested({
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.country,
    this.alias,
  });

  @override
  List<Object?> get props =>
      [bankName, accountNumber, accountType, currency, country, alias];
}

class DeleteBankAccountRequested extends BankAccountEvent {
  final String bankAccountId;

  const DeleteBankAccountRequested(this.bankAccountId);

  @override
  List<Object?> get props => [bankAccountId];
}
