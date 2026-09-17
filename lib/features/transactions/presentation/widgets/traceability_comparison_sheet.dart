import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/traceability_metrics.dart';

class TraceabilityComparisonSheet extends StatelessWidget {
  final TraceabilityMetrics metrics;

  const TraceabilityComparisonSheet({super.key, required this.metrics});

  static void show(BuildContext context, TraceabilityMetrics metrics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TraceabilityComparisonSheet(metrics: metrics),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auditoría de Trazabilidad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Blockchain vs Tradicional',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Score summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildScoreCard(
                  context, 
                  'Sagiro (Blockchain)', 
                  metrics.blockchainScore, 
                  AppTheme.primaryBlue,
                ),
                const SizedBox(width: 16),
                _buildScoreCard(
                  context, 
                  'Sistema Tradicional', 
                  metrics.traditionalScore, 
                  Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Comparison Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Métricas Detalladas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildComparisonRow(
                    context,
                    title: 'Puntos de Verificación',
                    blockchainValue: '${metrics.blockchainCheckpoints} checkpoints',
                    traditionalValue: '${metrics.traditionalCheckpoints} checkpoints',
                    isBetter: metrics.blockchainCheckpoints > metrics.traditionalCheckpoints,
                  ),
                  
                  _buildComparisonRow(
                    context,
                    title: 'Tiempo de Visibilidad',
                    blockchainValue: '${metrics.blockchainVisibilitySec} seg',
                    traditionalValue: '${metrics.traditionalVisibilitySec / 3600} hrs',
                    isBetter: metrics.blockchainVisibilitySec < metrics.traditionalVisibilitySec,
                  ),
                  
                  _buildComparisonRow(
                    context,
                    title: 'Auditabilidad Pública',
                    blockchainValue: metrics.txHash != null ? 'SÍ (TxHash: ${_shortenHash(metrics.txHash!)})' : 'SÍ',
                    traditionalValue: metrics.traditionalAuditability ? 'SÍ' : 'NO',
                    isBetter: metrics.blockchainAuditability,
                    copyableValue: metrics.txHash,
                  ),
                  
                  _buildComparisonRow(
                    context,
                    title: 'Inmutabilidad',
                    blockchainValue: metrics.blockNumber != null 
                        ? 'SÍ (Bloque #${metrics.blockNumber} | Gas: ${metrics.gasUsed ?? "N/A"})' 
                        : 'SÍ (Contrato Inteligente)',
                    traditionalValue: 'NO (Base de datos mutable)',
                    isBetter: true,
                  ),
                  
                  _buildComparisonRow(
                    context,
                    title: 'Verificación Criptográfica',
                    blockchainValue: metrics.remittanceHash != null 
                        ? 'Hash Remesa: ${_shortenHash(metrics.remittanceHash!)}\nFirmante: ${_shortenHash(metrics.signerAddress ?? "")}' 
                        : 'SÍ (Firmas + Hash)',
                    traditionalValue: 'NO',
                    isBetter: true,
                    copyableValue: metrics.remittanceHash,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (metrics.externalVerificationUrl != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(metrics.externalVerificationUrl!),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ver Registro Público en Polygonscan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortenHash(String hash) {
    if (hash.length <= 12) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}';
  }

  Widget _buildScoreCard(BuildContext context, String title, double score, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context, {
    required String title,
    required String blockchainValue,
    required String traditionalValue,
    required bool isBetter,
    String? copyableValue,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blockchain',
                      style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isBetter) 
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 14),
                          ),
                        Expanded(
                          child: InkWell(
                            onTap: copyableValue != null 
                                ? () {
                                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copiado: $copyableValue')));
                                  } 
                                : null,
                            child: Text(
                              blockchainValue,
                              style: TextStyle(
                                fontWeight: isBetter ? FontWeight.bold : FontWeight.normal,
                                color: isBetter && !isDark ? AppTheme.accentGreen : null,
                                fontFamily: copyableValue != null ? 'monospace' : null,
                                fontSize: copyableValue != null ? 10 : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tradicional',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      traditionalValue,
                      style: const TextStyle(color: Colors.grey),
                    ),
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
