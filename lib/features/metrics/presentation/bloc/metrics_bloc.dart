import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/metrics_remote_datasource.dart';
import '../../domain/entities/traceability_aggregate.dart';

part 'metrics_event.dart';
part 'metrics_state.dart';

class MetricsBloc extends Bloc<MetricsEvent, MetricsState> {
  final MetricsRemoteDataSource dataSource;

  MetricsBloc({required this.dataSource}) : super(MetricsInitial()) {
    on<LoadMetrics>(_onLoadMetrics);
    on<ChangeTimeRange>(_onChangeTimeRange);
  }

  factory MetricsBloc.create() {
    return MetricsBloc(
      dataSource: MetricsRemoteDataSource(client: http.Client()),
    );
  }

  Future<void> _onLoadMetrics(
    LoadMetrics event,
    Emitter<MetricsState> emit,
  ) async {
    emit(MetricsLoading(timeRange: event.timeRange));
    try {
      final now = DateTime.now().toUtc();
      String? from;
      switch (event.timeRange) {
        case '24h':
          from = now.subtract(const Duration(hours: 24)).toIso8601String();
          break;
        case '7d':
          from = now.subtract(const Duration(days: 7)).toIso8601String();
          break;
        case '30d':
          from = now.subtract(const Duration(days: 30)).toIso8601String();
          break;
        case 'all':
          from = DateTime(2020).toIso8601String();
          break;
        default:
          from = now.subtract(const Duration(days: 30)).toIso8601String();
      }

      final aggregate = await dataSource.getTraceabilityAggregate(
        from: from,
        to: now.toIso8601String(),
        corridor: event.corridor,
      );

      if (aggregate.metrics.isEmpty) {
        emit(MetricsEmpty(timeRange: event.timeRange));
      } else {
        emit(MetricsLoaded(
          aggregate: aggregate,
          timeRange: event.timeRange,
        ));
      }
    } catch (e) {
      emit(MetricsError(
        message: e.toString(),
        timeRange: event.timeRange,
      ));
    }
  }

  Future<void> _onChangeTimeRange(
    ChangeTimeRange event,
    Emitter<MetricsState> emit,
  ) async {
    add(LoadMetrics(timeRange: event.timeRange, corridor: event.corridor));
  }
}
