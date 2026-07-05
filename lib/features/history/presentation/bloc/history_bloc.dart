import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/get_transaction_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetTransactionHistory getTransactionHistory;
  
  Timer? _pollingTimer;

  HistoryBloc({required this.getTransactionHistory}) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<RefreshHistory>(_onRefreshHistory);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) {
        add(const RefreshHistory());
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefreshHistory(RefreshHistory event, Emitter<HistoryState> emit) async {
    final current = state;
    if (current is HistoryLoaded) {
      emit(HistoryLoaded(current.items, isRefreshing: true));
    } else {
      emit(const HistoryLoading());
    }
    await _fetchData(emit);
  }
  
  Future<void> _fetchData(Emitter<HistoryState> emit) async {
    try {
      final items = await getTransactionHistory(const NoParams());
      emit(HistoryLoaded(items));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
