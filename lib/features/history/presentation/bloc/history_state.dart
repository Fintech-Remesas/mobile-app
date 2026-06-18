part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryItem> items;

  const HistoryLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class HistoryError extends HistoryState {
  final String message;
  final int? statusCode;
  final String? title;
  final String? endpoint;
  final String? hint;
  final Object? originalError;

  const HistoryError({
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
