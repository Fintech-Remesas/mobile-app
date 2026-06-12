import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/get_transaction_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetTransactionHistory getTransactionHistory;

  HistoryBloc({required this.getTransactionHistory}) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    try {
      final items = await getTransactionHistory(const NoParams());
      emit(HistoryLoaded(items));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
