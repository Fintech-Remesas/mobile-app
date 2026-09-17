part of 'metrics_bloc.dart';

abstract class MetricsState extends Equatable {
  final String timeRange;

  const MetricsState({this.timeRange = '30d'});

  @override
  List<Object?> get props => [timeRange];
}

class MetricsInitial extends MetricsState {}

class MetricsLoading extends MetricsState {
  const MetricsLoading({super.timeRange});
}

class MetricsLoaded extends MetricsState {
  final TraceabilityAggregate aggregate;

  const MetricsLoaded({required this.aggregate, super.timeRange});

  @override
  List<Object?> get props => [aggregate, timeRange];
}

class MetricsEmpty extends MetricsState {
  const MetricsEmpty({super.timeRange});
}

class MetricsError extends MetricsState {
  final String message;

  const MetricsError({required this.message, super.timeRange});

  @override
  List<Object?> get props => [message, timeRange];
}
