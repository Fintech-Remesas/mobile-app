import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'presentation/bloc/metrics_bloc.dart';
import 'presentation/widgets/metric_card.dart';
import 'presentation/widgets/corridor_table.dart';

/// Panel "Auditoría y Trazabilidad" — 8 métricas agregadas + desglose corredor.
/// Cero lógica de cálculo: el widget recibe valores ya calculados por el backend.
class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MetricsBloc.create()..add(const LoadMetrics()),
      child: const _MetricsScreenContent(),
    );
  }
}

class _MetricsScreenContent extends StatelessWidget {
  const _MetricsScreenContent();

  // Mapea cada métrica a su ícono y color
  static const _metricStyles = <String, ({IconData icon, Color color})>{
    'traceability_index': (icon: LucideIcons.eye, color: Color(0xFF3B82F6)),
    'anchoring_rate': (icon: LucideIcons.anchor, color: Color(0xFF22C55E)),
    'independent_verifiability': (icon: LucideIcons.shieldCheck, color: Color(0xFF06B6D4)),
    'reconciliation_integrity': (icon: LucideIcons.checkCircle2, color: Color(0xFF8B5CF6)),
    'e2e_latency': (icon: LucideIcons.timer, color: Color(0xFFF59E0B)),
    'tx_success_rate': (icon: LucideIcons.zap, color: Color(0xFF10B981)),
    'avg_cost_per_remittance': (icon: LucideIcons.circleDollarSign, color: Color(0xFFA855F7)),
    'cost_ratio': (icon: LucideIcons.percent, color: Color(0xFFEC4899)),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        title: Text(
          'Auditoría y Trazabilidad',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<MetricsBloc, MetricsState>(
        builder: (context, state) {
          if (state is MetricsLoading) {
            return _buildLoadingSkeleton();
          }
          if (state is MetricsError) {
            return _buildError(context, state);
          }
          if (state is MetricsEmpty) {
            return _buildEmpty(context, state);
          }
          if (state is MetricsLoaded) {
            return _buildLoaded(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Esqueletos de carga — no un spinner a pantalla completa.
  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _skeletonBox(height: 30, width: 220),
        const SizedBox(height: 8),
        _skeletonBox(height: 16, width: double.infinity),
        const SizedBox(height: 24),
        _skeletonBox(height: 40, width: double.infinity),
        const SizedBox(height: 24),
        ...List.generate(8, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _skeletonBox(height: 72, width: double.infinity),
        )),
      ],
    );
  }

  Widget _skeletonBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildError(BuildContext context, MetricsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error cargando métricas',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MetricsBloc>().add(
                LoadMetrics(timeRange: state.timeRange),
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5F59F7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, MetricsEmpty state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.inbox, color: Colors.white24, size: 48),
            const SizedBox(height: 16),
            Text(
              'Sin datos de trazabilidad',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay remesas procesadas en el rango seleccionado. Procesa una remesa para ver las métricas.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, MetricsLoaded state) {
    final aggregate = state.aggregate;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MetricsBloc>().add(LoadMetrics(timeRange: state.timeRange));
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Título
          Text(
            'Métricas de Trazabilidad',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Calculadas desde datos reales en Polygon Amoy. Última actualización: ${_formatTime(aggregate.computedAt)}',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          // Selector de rango temporal
          _buildTimeRangeSelector(context, state.timeRange),
          const SizedBox(height: 24),

          // Las 8 métricas
          ...aggregate.metrics.map((metric) {
            final style = _metricStyles[metric.key];
            return MetricCard(
              metric: metric,
              icon: style?.icon ?? LucideIcons.barChart2,
              accentColor: style?.color ?? Colors.blueAccent,
            );
          }),

          const SizedBox(height: 32),

          // Desglose por corredor
          Text(
            'Desglose por Corredor',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Evidencia de bidireccionalidad: cada ruta origen → destino.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
          ),
          const SizedBox(height: 12),
          CorridorTable(corridors: aggregate.corridorBreakdown),

          const SizedBox(height: 32),

          // Nota de verificabilidad
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Todas las métricas provienen de recibos on-chain y datos reales. Las fórmulas SQL están documentadas en docs/METRICS.md.',
                    style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, String current) {
    const ranges = ['24h', '7d', '30d', 'all'];
    const labels = ['24h', '7 días', '30 días', 'Todo'];

    return Row(
      children: List.generate(ranges.length, (i) {
        final isSelected = ranges[i] == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<MetricsBloc>().add(
              ChangeTimeRange(timeRange: ranges[i]),
            ),
            child: Container(
              margin: EdgeInsets.only(right: i < ranges.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5F59F7)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5F59F7)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
