import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

import '../../domain/entities/traceability_aggregate.dart';

/// Datasource remoto para métricas de trazabilidad.
/// Habla con el Web3 Service directamente (no pasa por API Gateway).
class MetricsRemoteDataSource {
  final http.Client client;

  MetricsRemoteDataSource({required this.client});

  /// Obtiene las 8 métricas agregadas + desglose por corredor.
  Future<TraceabilityAggregate> getTraceabilityAggregate({
    String? from,
    String? to,
    String corridor = 'all',
  }) async {
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (corridor != 'all') queryParams['corridor'] = corridor;

    final url = Uri.parse(
      '${AppConstants.web3SocketUrl}${AppConstants.traceabilityMetricsEndpoint}',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return _parseAggregate(body);
    } else if (response.statusCode == 422) {
      throw Exception('Rango de fechas inválido');
    } else {
      throw Exception('Error cargando métricas: ${response.statusCode}');
    }
  }

  /// Obtiene métricas unitarias de una remesa.
  Future<Map<String, dynamic>> getUnitaryMetrics(String remittanceId) async {
    final url = Uri.parse(
      '${AppConstants.web3SocketUrl}${AppConstants.unitaryMetricsEndpoint(remittanceId)}',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw Exception('Remesa no encontrada');
    } else if (response.statusCode == 502) {
      throw Exception('Error de conexión RPC');
    } else {
      throw Exception('Error cargando métricas: ${response.statusCode}');
    }
  }

  TraceabilityAggregate _parseAggregate(Map<String, dynamic> json) {
    final metricsJson = json['metrics'] as List<dynamic>;
    final corridorJson = json['corridor_breakdown'] as List<dynamic>? ?? [];

    return TraceabilityAggregate(
      version: json['version']?.toString() ?? '1.0',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      corridor: json['corridor']?.toString() ?? 'all',
      computedAt: json['computed_at']?.toString() ?? '',
      metrics: metricsJson.map((m) {
        final mMap = m as Map<String, dynamic>;
        return AggregateMetric(
          key: mMap['key']?.toString() ?? '',
          label: mMap['label']?.toString() ?? '',
          value: mMap['value'],
          unit: mMap['unit']?.toString() ?? '',
          precision: (mMap['precision'] as num?)?.toInt() ?? 2,
          sampleSize: (mMap['sample_size'] as num?)?.toInt() ?? 0,
          computedAt: mMap['computed_at']?.toString() ?? '',
          lowConfidence: mMap['low_confidence'] == true,
          baseline: (mMap['baseline'] as num?)?.toDouble(),
          delta: (mMap['delta'] as num?)?.toDouble(),
          discrepancyCount: (mMap['discrepancy_count'] as num?)?.toInt(),
          valueWei: mMap['value_wei']?.toString(),
        );
      }).toList(),
      corridorBreakdown: corridorJson.map((c) {
        final cMap = c as Map<String, dynamic>;
        return CorridorBreakdown(
          originCountry: cMap['origin_country']?.toString() ?? '',
          destCountry: cMap['dest_country']?.toString() ?? '',
          remittanceCount: (cMap['remittance_count'] as num?)?.toInt() ?? 0,
          volumeUsd: (cMap['volume_usd'] as num?)?.toDouble(),
          latencyP95: (cMap['latency_p95'] as num?)?.toDouble(),
          anchoringRate: (cMap['anchoring_rate'] as num?)?.toDouble(),
        );
      }).toList(),
    );
  }
}
