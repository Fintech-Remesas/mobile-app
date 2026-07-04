part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final WalletSummary wallet;
  final List<TransactionPreview> transactions;
  final List<LedgerMovement> ledgerMovements;
  final bool isRefreshing;

  const HomeLoaded({
    required this.wallet,
    required this.transactions,
    required this.ledgerMovements,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [wallet, transactions, ledgerMovements, isRefreshing];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
