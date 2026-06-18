import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/error_state_view.dart';
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
      if (e is ApiException) {
        emit(HistoryError(
          message: e.message,
          statusCode: e.statusCode,
          title: e.title,
          endpoint: e.endpoint,
          hint: ErrorStateView.hintForApiException(e),
          originalError: e,
        ));
      } else {
        emit(HistoryError(message: e.toString(), originalError: e));
      }
    }
  }
}
