import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_page.dart';
import '../../domain/usecases/get_transaction_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetTransactionHistory getTransactionHistory;
  static const _pageSize = 20;

  HistoryBloc({required this.getTransactionHistory}) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<LoadMoreHistory>(_onLoadMoreHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final page = await getTransactionHistory(
        const GetTransactionHistoryParams(page: 0, size: _pageSize),
      );
      emit(HistoryLoaded(
        items: page.items,
        total: page.total,
        currentPage: page.page,
        summary: page.summary,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(_errorFrom(e));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state;
    if (current is! HistoryLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final page = await getTransactionHistory(
        GetTransactionHistoryParams(page: nextPage, size: _pageSize),
      );
      emit(HistoryLoaded(
        items: [...current.items, ...page.items],
        total: page.total,
        currentPage: page.page,
        summary: page.summary,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      emit(current.copyWith(
        isLoadingMore: false,
        loadMoreError: _messageFrom(e),
      ));
    }
  }

  HistoryError _errorFrom(Object e) {
    if (e is ApiException) {
      return HistoryError(
        message: e.message,
        statusCode: e.statusCode,
        title: e.title,
        endpoint: e.endpoint,
        hint: ErrorStateView.hintForApiException(e),
        originalError: e,
      );
    }
    return HistoryError(message: e.toString(), originalError: e);
  }

  String _messageFrom(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }
}
