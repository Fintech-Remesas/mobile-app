import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

enum PolygonConfirmationStatus { confirmed, pending }

enum PolygonNetwork { amoyTestnet, mainnet }

class PolygonNodeCard extends StatelessWidget {
  final String transactionHash;
  final PolygonNetwork network;
  final int blockNumber;
  final PolygonConfirmationStatus status;
  final DateTime blockTimestamp;
  final String? polygonscanUrl;
  final VoidCallback? onViewOnPolygonscan;

  const PolygonNodeCard({
    super.key,
    required this.transactionHash,
    required this.network,
    required this.blockNumber,
    required this.status,
    required this.blockTimestamp,
    this.polygonscanUrl,
    this.onViewOnPolygonscan,
  });

  String get _resolvedPolygonscanUrl {
    if (polygonscanUrl != null) return polygonscanUrl!;
    final base = network == PolygonNetwork.mainnet
        ? 'https://polygonscan.com/tx/'
        : 'https://amoy.polygonscan.com/tx/';
    return '$base$transactionHash';
  }

  static String truncateHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }

  static String formatNetwork(PolygonNetwork network) {
    return switch (network) {
      PolygonNetwork.amoyTestnet => 'Polygon Amoy Testnet',
      PolygonNetwork.mainnet => 'Polygon Mainnet',
    };
  }

  static String formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  void _copyToClipboard(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _handleViewOnPolygonscan(BuildContext context) {
    if (onViewOnPolygonscan != null) {
      onViewOnPolygonscan!();
      return;
    }
    _copyToClipboard(
      context,
      _resolvedPolygonscanUrl,
      'Enlace de Polygonscan copiado al portapapeles',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppTheme.primaryBlue, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PolygonHexagonIcon(size: 22),
              const SizedBox(width: 10),
              Text(
                'Trazabilidad Polygon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Transaction Hash',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    truncateHash(transactionHash),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: AppTheme.primaryBlue,
                  tooltip: 'Copiar hash',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyToClipboard(
                    context,
                    transactionHash,
                    'Hash copiado al portapapeles',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  color: AppTheme.secondaryBlue,
                  tooltip: 'Ver en Polygonscan',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _handleViewOnPolygonscan(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Red',
            child: Text(
              formatNetwork(network),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Número de bloque',
            child: Text(
              blockNumber.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Estado de confirmación',
            child: _ConfirmationBadge(status: status),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Timestamp del bloque',
            child: Text(
              formatTimestamp(blockTimestamp),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleViewOnPolygonscan(context),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Ver en Polygonscan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.secondaryBlue,
                side: const BorderSide(color: AppTheme.secondaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _InfoRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _ConfirmationBadge extends StatelessWidget {
  final PolygonConfirmationStatus status;

  const _ConfirmationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == PolygonConfirmationStatus.confirmed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isConfirmed
            ? AppTheme.accentGreen.withOpacity(0.18)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed
              ? AppTheme.accentGreen.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: Text(
        isConfirmed ? 'Confirmado' : 'Pendiente',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isConfirmed ? AppTheme.accentGreen : Colors.orange.shade800,
        ),
      ),
    );
  }
}

class _PolygonHexagonIcon extends StatelessWidget {
  final double size;

  const _PolygonHexagonIcon({required this.size});

  static const Color _polygonPurple = Color(0xFF8247E5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(color: _polygonPurple),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;

  _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final radius = w / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (60 * i - 30) * math.pi / 180;
      final x = cx + radius * 0.9 * math.cos(angle);
      final y = cy + radius * 0.9 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
