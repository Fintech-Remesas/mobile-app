/// Entidad del dominio para una métrica agregada individual.
/// El widget recibe un valor ya calculado y lo formatea — cero lógica de cálculo.
class AggregateMetric {
  final String key;
  final String label;
  final dynamic value; // num, null, or Map (for e2e_latency p50/p95)
  final String unit;
  final int precision;
  final int sampleSize;
  final String computedAt;
  final bool lowConfidence;
  // Opcionales (según la métrica)
  final double? baseline;
  final double? delta;
  final int? discrepancyCount;
  final String? valueWei;

  const AggregateMetric({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.precision,
    required this.sampleSize,
    required this.computedAt,
    required this.lowConfidence,
    this.baseline,
    this.delta,
    this.discrepancyCount,
    this.valueWei,
  });
}

/// Fila del desglose por corredor.
class CorridorBreakdown {
  final String originCountry;
  final String destCountry;
  final int remittanceCount;
  final double? volumeUsd;
  final double? latencyP95;
  final double? anchoringRate;

  const CorridorBreakdown({
    required this.originCountry,
    required this.destCountry,
    required this.remittanceCount,
    this.volumeUsd,
    this.latencyP95,
    this.anchoringRate,
  });
}

/// Resultado completo del endpoint de métricas agregadas.
class TraceabilityAggregate {
  final String version;
  final String from;
  final String to;
  final String corridor;
  final String computedAt;
  final List<AggregateMetric> metrics;
  final List<CorridorBreakdown> corridorBreakdown;

  const TraceabilityAggregate({
    required this.version,
    required this.from,
    required this.to,
    required this.corridor,
    required this.computedAt,
    required this.metrics,
    required this.corridorBreakdown,
  });
}
