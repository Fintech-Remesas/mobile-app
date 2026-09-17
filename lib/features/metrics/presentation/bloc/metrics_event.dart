part of 'metrics_bloc.dart';

abstract class MetricsEvent extends Equatable {
  const MetricsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMetrics extends MetricsEvent {
  final String timeRange;
  final String corridor;

  const LoadMetrics({this.timeRange = '30d', this.corridor = 'all'});

  @override
  List<Object?> get props => [timeRange, corridor];
}

class ChangeTimeRange extends MetricsEvent {
  final String timeRange;
  final String corridor;

  const ChangeTimeRange({required this.timeRange, this.corridor = 'all'});

  @override
  List<Object?> get props => [timeRange, corridor];
}
