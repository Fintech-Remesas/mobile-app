part of 'bank_account_bloc.dart';

abstract class BankAccountState extends Equatable {
  const BankAccountState();

  @override
  List<Object?> get props => [];
}

class BankAccountInitial extends BankAccountState {
  const BankAccountInitial();
}

class BankAccountLoading extends BankAccountState {
  const BankAccountLoading();
}

class BankAccountSubmitting extends BankAccountState {
  final List<BankAccount> accounts;

  const BankAccountSubmitting(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class BankAccountLoaded extends BankAccountState {
  final List<BankAccount> accounts;
  final String? successMessage;

  const BankAccountLoaded(this.accounts, {this.successMessage});

  @override
  List<Object?> get props => [accounts, successMessage];
}

class BankAccountError extends BankAccountState {
  final String message;
  final List<BankAccount> accounts;

  const BankAccountError(this.message, {this.accounts = const []});

  @override
  List<Object?> get props => [message, accounts];
}
