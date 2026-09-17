import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';

/// Panel "Datos de Trazabilidad" — 9 elementos unitarios por remesa.
/// Usa el backend para obtener datos, pero la verificación independiente
/// llama directamente al RPC público sin pasar por Sagiro.
class TraceabilityMetricsView extends StatefulWidget {
  final dynamic remittance;
  final dynamic timeline;

  const TraceabilityMetricsView({
    super.key,
    required this.remittance,
    required this.timeline,
  });

  @override
  State<TraceabilityMetricsView> createState() => _TraceabilityMetricsViewState();
}

class _TraceabilityMetricsViewState extends State<TraceabilityMetricsView> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? metricsData;

  @override
  void initState() {
    super.initState();
    _fetchUnitaryMetrics();
  }

  Future<void> _fetchUnitaryMetrics() async {
    try {
      final remittanceId = widget.remittance.remittanceId;
      final url = Uri.parse(
        '${AppConstants.web3SocketUrl}${AppConstants.unitaryMetricsEndpoint(remittanceId)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            metricsData = json.decode(response.body);
            isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          setState(() {
            errorMessage = 'No se encontraron datos de trazabilidad para esta remesa. ¿Ya fue procesada on-chain?';
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'Error cargando métricas: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error conectando al servicio: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Icon(LucideIcons.barChart2, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Datos de Trazabilidad',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Evidencia extraída directamente de la red Polygon Amoy.',
              style: GoogleFonts.inter(color: Colors.blueGrey[300], fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: isLoading
                ? _buildLoadingSkeleton()
                : errorMessage != null
                    ? _buildError()
                    : metricsData != null
                        ? _buildMetricsList()
                        : _buildEmpty(),
          ),

          // Botones de acción
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (metricsData != null && metricsData!['remittanceHash'] != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E).withOpacity(0.15),
                          foregroundColor: const Color(0xFF22C55E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: const Color(0xFF22C55E).withOpacity(0.3)),
                        ),
                        icon: const Icon(LucideIcons.shieldCheck, size: 20),
                        label: Text(
                          'Verificar de Forma Independiente',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        onPressed: () => _showIndependentVerification(context),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar Panel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: List.generate(9, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() { isLoading = true; errorMessage = null; });
                _fetchUnitaryMetrics();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'Sin datos de trazabilidad disponibles.',
        style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
      ),
    );
  }

  Widget _buildMetricsList() {
    final d = metricsData!;
    final timeline = d['timeline'] as Map<String, dynamic>?;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // ── 1. Línea de tiempo del rastro ─────────────────────────────────────
        if (timeline != null) _buildTimeline(timeline),
        const SizedBox(height: 16),

        // ── 2. TX Hash ───────────────────────────────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.hash,
          title: 'TX Hash',
          subtitle: 'Identificador único en la blockchain',
          value: _truncateHash(d['txHash']?.toString()),
          valueColor: Colors.blueAccent,
          isVerifiable: true,
          onCopy: d['txHash'] != null ? () => _copy(d['txHash']) : null,
          onExplorer: d['explorerUrl'] != null ? () => _launchUrl(d['explorerUrl']) : null,
        ),
        const SizedBox(height: 10),

        // ── 3. Bloque de inclusión ───────────────────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.layers,
          title: 'Bloque de inclusión',
          subtitle: 'Número del bloque donde se selló la TX',
          value: d['blockNumber']?.toString(),
          valueColor: Colors.cyanAccent,
          isVerifiable: true,
        ),
        const SizedBox(height: 10),

        // ── 4. Confirmaciones ────────────────────────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.checkCircle2,
          title: 'Confirmaciones',
          subtitle: 'Bloques acumulados desde la inclusión',
          value: d['confirmations']?.toString(),
          valueColor: Colors.greenAccent,
          isVerifiable: true,
        ),
        const SizedBox(height: 10),

        // ── 5. TTFE — Tiempo hasta evidencia verificable ────────────────────
        _buildMetricCard(
          icon: LucideIcons.timer,
          title: 'Tiempo hasta evidencia (TTFE)',
          subtitle: 'Desde creación hasta finalización on-chain',
          value: d['ttfeSec'] != null ? '${d['ttfeSec']} s' : null,
          valueColor: Colors.amberAccent,
          isVerifiable: false,
        ),
        const SizedBox(height: 10),

        // ── 6. Tiempo de inclusión en bloque ────────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.clock,
          title: 'Tiempo de inclusión en bloque',
          subtitle: 'Tiempo en mempool hasta ser minada',
          value: d['inclusionTimeSec'] != null ? '${d['inclusionTimeSec']} s' : null,
          valueColor: Colors.orangeAccent,
          isVerifiable: false,
        ),
        const SizedBox(height: 10),

        // ── 7. Gas consumido y función invocada ─────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.fuel,
          title: 'Gas consumido',
          subtitle: d['methodName'] != null
              ? 'Función: ${d['methodName']}'
              : 'Función invocada en el contrato',
          value: d['gasUsed']?.toString(),
          valueColor: Colors.deepOrangeAccent,
          isVerifiable: true,
        ),
        const SizedBox(height: 10),

        // ── 8. Costo operativo ──────────────────────────────────────────────
        _buildMetricCard(
          icon: LucideIcons.circleDollarSign,
          title: 'Costo operativo',
          subtitle: d['costPercent'] != null
              ? '${d['costPercent']}% del monto remesado (\$${d['amountUsd']?.toStringAsFixed(2) ?? "?"})'
              : 'Costo real pagado a la red Polygon',
          value: d['costUsd'] != null ? '\$${(d['costUsd'] as num).toStringAsFixed(6)}' : null,
          valueColor: Colors.purpleAccent,
          isVerifiable: true,
        ),
        const SizedBox(height: 10),

        // ── 9. Estado de conciliación ───────────────────────────────────────
        _buildReconciliationBadge(d),

        const SizedBox(height: 24),

        // Nota
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_outlined, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Los datos con ícono verde son verificables independientemente en Polygonscan.',
                  style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// ── 1. Línea de tiempo visual del rastro ─────────────────────────────────
  Widget _buildTimeline(Map<String, dynamic> timeline) {
    final milestones = <({String label, String? time, Color color, bool completed})>[
      (
        label: 'Registrado',
        time: timeline['registered'],
        color: const Color(0xFF3B82F6),
        completed: timeline['registered'] != null,
      ),
      (
        label: 'TX Enviada',
        time: timeline['txSent'],
        color: const Color(0xFFF59E0B),
        completed: timeline['txSent'] != null,
      ),
      (
        label: 'Minada',
        time: timeline['txMined'],
        color: const Color(0xFF22C55E),
        completed: timeline['txMined'] != null,
      ),
      (
        label: 'Confirmada',
        time: timeline['confirmed'],
        color: const Color(0xFF06B6D4),
        completed: timeline['confirmed'] != null,
      ),
      (
        label: 'Completada',
        time: timeline['completed'],
        color: const Color(0xFF8B5CF6),
        completed: timeline['completed'] != null,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Línea de Tiempo del Rastro',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isLast = i == milestones.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot + line
                Column(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: m.completed ? m.color : Colors.white12,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: m.completed ? m.color : Colors.white24,
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2, height: 28,
                        color: m.completed ? m.color.withOpacity(0.4) : Colors.white10,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Label + time
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m.label,
                          style: GoogleFonts.inter(
                            color: m.completed ? Colors.white : Colors.white30,
                            fontSize: 13,
                            fontWeight: m.completed ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (m.time != null)
                          Text(
                            _formatTimestamp(m.time!),
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// ── 9. Badge de conciliación ─────────────────────────────────────────────
  Widget _buildReconciliationBadge(Map<String, dynamic> d) {
    final reconciled = d['reconciled'];
    final discrepancy = d['discrepancy']?.toString();

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (reconciled == true) {
      badgeColor = Colors.greenAccent;
      badgeText = 'Verificado';
      badgeIcon = LucideIcons.checkCircle2;
    } else if (reconciled == false) {
      badgeColor = Colors.redAccent;
      badgeText = 'Discrepancia';
      badgeIcon = LucideIcons.alertTriangle;
    } else {
      badgeColor = Colors.amber;
      badgeText = 'Pendiente';
      badgeIcon = LucideIcons.clock;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Conciliación',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reconciled == null
                      ? 'Aún no se ha verificado la consistencia DB ↔ Blockchain'
                      : reconciled == true
                          ? 'Los datos del sistema coinciden con la blockchain'
                          : 'Se detectaron diferencias entre el sistema y la blockchain',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                ),
                if (discrepancy != null && discrepancy.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    discrepancy,
                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.inter(
                color: badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? value,
    required Color valueColor,
    required bool isVerifiable,
    VoidCallback? onCopy,
    VoidCallback? onExplorer,
  }) {
    final displayValue = value ?? '—';
    final truncated = displayValue.length > 22
        ? '${displayValue.substring(0, 10)}...${displayValue.substring(displayValue.length - 8)}'
        : displayValue;

    return Semantics(
      label: '$title: ${value ?? "sin datos"}. $subtitle',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: valueColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: valueColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isVerifiable)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_outlined, color: Colors.greenAccent, size: 15),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(color: Colors.blueGrey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              IconButton(
                icon: const Icon(LucideIcons.copy, color: Colors.white38, size: 16),
                onPressed: onCopy,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            if (onExplorer != null)
              IconButton(
                icon: const Icon(LucideIcons.externalLink, color: Colors.white38, size: 16),
                onPressed: onExplorer,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            if (onCopy == null && onExplorer == null)
              Text(
                truncated,
                style: GoogleFonts.outfit(
                  color: value == null ? Colors.white24 : valueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ── Verificación Independiente (sin backend) ────────────────────────────
  void _showIndependentVerification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _IndependentVerifyPanel(
        remittanceId: metricsData!['remittanceId'],
        remittanceHash: metricsData!['remittanceHash'],
        sagiroData: metricsData!,
      ),
    );
  }

  String? _truncateHash(String? hash) {
    if (hash == null) return null;
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }

  String _formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  void _copy(String? text) {
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copiado al portapapeles'), backgroundColor: Colors.black87),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// ── Panel de Verificación Independiente ─────────────────────────────────────
/// Llama directamente al RPC público de Polygon Amoy, sin pasar por el backend
/// de Sagiro. Este es el corazón de la tesis: la trazabilidad no consiste en
/// que el sistema muestre un estado, sino en que el usuario pueda comprobarlo
/// sin confiar en el sistema.
class _IndependentVerifyPanel extends StatefulWidget {
  final String remittanceId;
  final String remittanceHash;
  final Map<String, dynamic> sagiroData;

  const _IndependentVerifyPanel({
    required this.remittanceId,
    required this.remittanceHash,
    required this.sagiroData,
  });

  @override
  State<_IndependentVerifyPanel> createState() => _IndependentVerifyPanelState();
}

class _IndependentVerifyPanelState extends State<_IndependentVerifyPanel> {
  bool isVerifying = true;
  String? errorMessage;
  Map<String, dynamic>? onChainData;
  String verdict = 'PENDING';

  @override
  void initState() {
    super.initState();
    _verifyOnChain();
  }

  /// Llama directamente al RPC público para leer getRemittance(hash)
  /// via eth_call. NO pasa por el backend de Sagiro.
  Future<void> _verifyOnChain() async {
    try {
      // getRemittance(bytes32) selector = primeros 4 bytes de keccak256("getRemittance(bytes32)")
      // = 0xf3fe3bc3 (pre-calculado)
      final callData = '0xf3fe3bc3${widget.remittanceHash.substring(2).padLeft(64, '0')}';

      final rpcUrl = Uri.parse(AppConstants.polygonAmoyRpcUrl);
      final rpcPayload = json.encode({
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': AppConstants.registryContractAddress,
            'data': callData,
          },
          'latest',
        ],
        'id': 1,
      });

      final response = await http.post(
        rpcUrl,
        headers: {'Content-Type': 'application/json'},
        body: rpcPayload,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['error'] != null) {
          setState(() {
            errorMessage = 'Contrato respondió con error: ${body['error']['message']}';
            isVerifying = false;
          });
          return;
        }

        final result = body['result']?.toString() ?? '';

        if (result == '0x' || result.isEmpty || result == '0x0') {
          setState(() {
            onChainData = null;
            verdict = 'NOT_FOUND_ON_CHAIN';
            isVerifying = false;
          });
          return;
        }

        // Decodificar el resultado ABI
        final decoded = _decodeGetRemittanceResult(result);
        final sagiroAmount = widget.sagiroData['amountUsd'];

        // Comparar
        bool matches = true;
        if (decoded['amountUsdCents'] != null && sagiroAmount != null) {
          final sagiroCents = (sagiroAmount * 100).round();
          if (sagiroCents != decoded['amountUsdCents']) matches = false;
        }

        setState(() {
          onChainData = decoded;
          verdict = matches ? 'MATCH' : 'MISMATCH';
          isVerifying = false;
        });
      } else {
        setState(() {
          errorMessage = 'RPC público respondió: ${response.statusCode}';
          isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error verificando: $e';
        isVerifying = false;
      });
    }
  }

  Map<String, dynamic> _decodeGetRemittanceResult(String hex) {
    // La respuesta de getRemittance es un tuple ABI-encoded.
    // Decodificamos los primeros campos que podemos leer:
    // amountUSD (uint256), senderCountry (offset), recipientCountry (offset), ...
    // status es el último uint8 (enum)
    try {
      final data = hex.startsWith('0x') ? hex.substring(2) : hex;
      if (data.length < 64) return {};

      // word 0: amountUSD (uint256 en centavos)
      final amountHex = data.substring(0, 64);
      final amountCents = int.tryParse(amountHex, radix: 16) ?? 0;

      // Los strings son dinámicos y requieren offsets — simplificamos
      // word 5 (registeredAt), word 6 (confirmedAt), word 7 (completedAt)
      // Cada word es 64 chars (32 bytes)
      int wordAt(int index) {
        final start = index * 64;
        if (start + 64 > data.length) return 0;
        return int.tryParse(data.substring(start, start + 64), radix: 16) ?? 0;
      }

      // word 10: status (enum)
      final status = wordAt(10);
      final statusNames = ['REGISTERED', 'IN_BLOCKCHAIN', 'CONFIRMED', 'COMPLETED', 'FAILED'];

      return {
        'amountUsdCents': amountCents,
        'amountUsd': amountCents / 100,
        'status': status < statusNames.length ? statusNames[status] : 'UNKNOWN',
        'statusCode': status,
        'source': 'Polygon Amoy (RPC público)',
      };
    } catch (e) {
      return {'error': 'Error decodificando: $e'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck, color: Color(0xFF22C55E), size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verificación Independiente',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Consulta directa al RPC público',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: isVerifying
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF22C55E)),
                        const SizedBox(height: 16),
                        Text(
                          'Consultando ${AppConstants.polygonAmoyRpcUrl}...\nSin pasar por el backend de Sagiro.',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.wifiOff, color: Colors.redAccent, size: 40),
                              const SizedBox(height: 12),
                              Text(errorMessage!, style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                'La verificación independiente funciona incluso con el backend de Sagiro apagado, '
                                'pero requiere conexión a Internet para alcanzar el RPC público de Polygon.',
                                style: GoogleFonts.inter(color: Colors.white24, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildComparison(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    final verdictColor = verdict == 'MATCH'
        ? Colors.greenAccent
        : verdict == 'MISMATCH'
            ? Colors.redAccent
            : Colors.amber;

    final verdictText = verdict == 'MATCH'
        ? '✅ COINCIDE'
        : verdict == 'MISMATCH'
            ? '❌ NO COINCIDE'
            : '⚠️ No encontrada en blockchain';

    final verdictDesc = verdict == 'MATCH'
        ? 'Los datos en Sagiro coinciden con la blockchain. La integridad está verificada.'
        : verdict == 'MISMATCH'
            ? 'Se detectaron diferencias entre Sagiro y la blockchain.'
            : 'La remesa no fue encontrada en el smart contract.';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Veredicto
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: verdictColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: verdictColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(verdictText, style: GoogleFonts.outfit(color: verdictColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(verdictDesc, style: GoogleFonts.inter(color: verdictColor.withOpacity(0.8), fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tabla comparativa
        if (onChainData != null) ...[
          Text('Comparación lado a lado', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _compareRow('Monto USD',
            '\$${widget.sagiroData['amountUsd']?.toStringAsFixed(2) ?? "?"}',
            '\$${onChainData!['amountUsd']?.toStringAsFixed(2) ?? "?"}'),
          _compareRow('Estado',
            widget.sagiroData['txStatus'] == 1 ? 'Confirmado' : 'Pendiente',
            onChainData!['status']?.toString() ?? '?'),
          _compareRow('Fuente',
            'Base de datos Sagiro',
            onChainData!['source']?.toString() ?? 'Blockchain'),
        ],

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta verificación se realizó directamente contra el RPC público de Polygon Amoy '
                  '(${AppConstants.polygonAmoyRpcUrl}), sin pasar por ningún servidor de Sagiro.',
                  style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _compareRow(String label, String sagiro, String chain) {
    final match = sagiro.toLowerCase() == chain.toLowerCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sagiro', style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(sagiro, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(
                match ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                color: match ? Colors.greenAccent : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Blockchain', style: GoogleFonts.inter(color: const Color(0xFF22C55E), fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(chain, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
