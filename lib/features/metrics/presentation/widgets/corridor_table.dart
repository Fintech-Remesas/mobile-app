import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/traceability_aggregate.dart';

/// Tabla de desglose por corredor — evidencia la bidireccionalidad.
class CorridorTable extends StatelessWidget {
  final List<CorridorBreakdown> corridors;

  const CorridorTable({super.key, required this.corridors});

  @override
  Widget build(BuildContext context) {
    if (corridors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No hay datos de corredores en el rango seleccionado.',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _headerCell('Corredor', flex: 2),
                _headerCell('Remesas', flex: 1),
                _headerCell('Vol. USD', flex: 2),
                _headerCell('P95 (s)', flex: 1),
                _headerCell('Anclaje', flex: 1),
              ],
            ),
          ),
          // Rows
          ...corridors.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.transparent : Colors.white.withOpacity(0.02),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${c.originCountry} → ${c.destCountry}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _dataCell('${c.remittanceCount}', flex: 1),
                  _dataCell(
                    c.volumeUsd != null ? '\$${c.volumeUsd!.toStringAsFixed(2)}' : '—',
                    flex: 2,
                  ),
                  _dataCell(
                    c.latencyP95 != null ? c.latencyP95!.toStringAsFixed(1) : '—',
                    flex: 1,
                  ),
                  _dataCell(
                    c.anchoringRate != null ? '${c.anchoringRate!.toStringAsFixed(1)}%' : '—',
                    flex: 1,
                    color: c.anchoringRate != null && c.anchoringRate! >= 80
                        ? Colors.greenAccent
                        : Colors.white70,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1, Color color = Colors.white70}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
}
