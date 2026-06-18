import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../domain/entities/transaction_preview.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/get_recent_transactions.dart';
import '../../domain/usecases/get_wallet_summary.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetWalletSummary getWalletSummary;
  final GetRecentTransactions getRecentTransactions;

  HomeBloc({
    required this.getWalletSummary,
    required this.getRecentTransactions,
  }) : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<RefreshHome>(_onRefreshHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefreshHome(RefreshHome event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(wallet: current.wallet, transactions: current.transactions, isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    try {
      final results = await Future.wait([
        getWalletSummary(const NoParams()),
        getRecentTransactions(const NoParams()),
      ]);
      emit(HomeLoaded(
        wallet: results[0] as WalletSummary,
        transactions: results[1] as List<TransactionPreview>,
      ));
    } catch (e) {
      if (e is ApiException) {
        emit(HomeError(
          message: e.message,
          statusCode: e.statusCode,
          title: e.title,
          endpoint: e.endpoint,
          hint: ErrorStateView.hintForApiException(e),
          originalError: e,
        ));
      } else {
        emit(HomeError(message: e.toString(), originalError: e));
      }
    }
  }
}
