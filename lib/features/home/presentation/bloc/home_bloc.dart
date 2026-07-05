import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/ledger_movement.dart';
import '../../domain/entities/transaction_preview.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/get_ledger_movements.dart';
import '../../domain/usecases/get_recent_transactions.dart';
import '../../domain/usecases/get_wallet_summary.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetWalletSummary getWalletSummary;
  final GetRecentTransactions getRecentTransactions;
  final GetLedgerMovements getLedgerMovements;
  
  Timer? _pollingTimer;

  HomeBloc({
    required this.getWalletSummary,
    required this.getRecentTransactions,
    required this.getLedgerMovements,
  }) : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<RefreshHome>(_onRefreshHome);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) {
        add(const RefreshHome());
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefreshHome(RefreshHome event, Emitter<HomeState> emit) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(
        wallet: current.wallet,
        transactions: current.transactions,
        ledgerMovements: current.ledgerMovements,
        isRefreshing: true,
      ));
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
        getLedgerMovements(const NoParams()),
      ]);
      emit(HomeLoaded(
        wallet: results[0] as WalletSummary,
        transactions: results[1] as List<TransactionPreview>,
        ledgerMovements: results[2] as List<LedgerMovement>,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
