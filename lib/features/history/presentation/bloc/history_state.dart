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
  final int total;
  final int currentPage;
  final RemittanceSummary? summary;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  const HistoryLoaded({
    required this.items,
    required this.total,
    required this.currentPage,
    this.summary,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  HistoryLoaded copyWith({
    List<HistoryItem>? items,
    int? total,
    int? currentPage,
    RemittanceSummary? summary,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
  }) {
    return HistoryLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      summary: summary ?? this.summary,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
        items,
        total,
        currentPage,
        summary,
        hasMore,
        isLoadingMore,
        loadMoreError,
      ];
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
