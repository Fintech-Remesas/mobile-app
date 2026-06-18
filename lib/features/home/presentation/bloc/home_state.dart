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
  final bool isRefreshing;

  const HomeLoaded({
    required this.wallet,
    required this.transactions,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [wallet, transactions, isRefreshing];
}

class HomeError extends HomeState {
  final String message;
  final int? statusCode;
  final String? title;
  final String? endpoint;
  final String? hint;
  final Object? originalError;

  const HomeError({
    required this.message,
    this.statusCode,
    this.title,
    this.endpoint,
    this.hint,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, statusCode, title, endpoint, hint];
}
