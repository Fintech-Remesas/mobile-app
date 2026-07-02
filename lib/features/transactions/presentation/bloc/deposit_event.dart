part of 'deposit_bloc.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeposit extends DepositEvent {
  final String id;

  const LoadDeposit(this.id);

  @override
  List<Object?> get props => [id];
}

class ConfirmDepositRequested extends DepositEvent {
  final String id;

  const ConfirmDepositRequested(this.id);

  @override
  List<Object?> get props => [id];
}
