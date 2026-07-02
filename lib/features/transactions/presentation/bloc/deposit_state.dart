part of 'deposit_bloc.dart';

abstract class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {
  const DepositInitial();
}

class DepositLoading extends DepositState {
  const DepositLoading();
}

class DepositLoaded extends DepositState {
  final Remittance remittance;
  final String? errorMessage;

  const DepositLoaded(this.remittance, {this.errorMessage});

  @override
  List<Object?> get props => [remittance, errorMessage];
}

class DepositConfirming extends DepositState {
  final Remittance remittance;

  const DepositConfirming(this.remittance);

  @override
  List<Object?> get props => [remittance];
}

class DepositConfirmed extends DepositState {
  final Remittance remittance;

  const DepositConfirmed(this.remittance);

  @override
  List<Object?> get props => [remittance];
}

class DepositError extends DepositState {
  final String message;

  const DepositError(this.message);

  @override
  List<Object?> get props => [message];
}
