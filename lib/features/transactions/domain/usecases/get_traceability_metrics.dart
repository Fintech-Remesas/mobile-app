// lib/features/transactions/domain/usecases/get_traceability_metrics.dart

import '../entities/traceability_metrics.dart';
import '../repositories/transaction_repository.dart';

class GetTraceabilityMetrics {
  final TransactionRepository repository;

  GetTraceabilityMetrics(this.repository);

  Future<TraceabilityMetrics> call(GetTraceabilityMetricsParams params) async {
    return await repository.getTraceabilityMetrics(params.remittanceId);
  }
}

class GetTraceabilityMetricsParams {
  final String remittanceId;

  GetTraceabilityMetricsParams({required this.remittanceId});
}
