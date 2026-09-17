import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/traceability_aggregate.dart';

/// Widget reutilizable para una métrica individual del panel de Auditoría.
/// Una única card parametrizable para las 8 métricas — no 8 widgets idénticos.
class MetricCard extends StatelessWidget {
  final AggregateMetric metric;
  final IconData icon;
  final Color accentColor;

  const MetricCard({
    super.key,
    required this.metric,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${metric.label}: ${_formatValue()} ${metric.unit}. '
          'Muestra de ${metric.sampleSize} remesas. '
          '${metric.lowConfidence ? "Confianza baja, muestra menor a 30." : ""}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // Ícono con fondo de color
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Título + subtítulo descriptivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'n = ${metric.sampleSize}',
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      if (metric.lowConfidence) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'baja confianza',
                            style: GoogleFonts.inter(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Valor a la derecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatValue(),
                  style: GoogleFonts.outfit(
                    color: metric.value == null ? Colors.white24 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  metric.value == null ? '' : metric.unit,
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Delta vs baseline (solo para cost_ratio)
                if (metric.delta != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${metric.delta! >= 0 ? "+" : ""}${metric.delta!.toStringAsFixed(3)}% vs ${metric.baseline?.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      color: metric.delta! <= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                // Discrepancy count (solo para reconciliation)
                if (metric.discrepancyCount != null && metric.discrepancyCount! > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${metric.discrepancyCount} discrepancias',
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue() {
    if (metric.value == null) return '—';

    // Caso especial: e2e_latency tiene p50 y p95
    if (metric.value is Map) {
      final map = metric.value as Map<String, dynamic>;
      final p50 = map['p50'];
      final p95 = map['p95'];
      if (p50 == null && p95 == null) return '—';
      return 'p50: ${_num(p50, 1)}  p95: ${_num(p95, 1)}';
    }

    if (metric.value is num) {
      return _num(metric.value as num, metric.precision);
    }

    return metric.value.toString();
  }

  String _num(num? val, int decimals) {
    if (val == null) return '—';
    return NumberFormat.decimalPatternDigits(
      locale: 'es',
      decimalDigits: decimals,
    ).format(val);
  }
}
