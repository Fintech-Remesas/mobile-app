import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../network/api_exception.dart';

class ErrorStateView extends StatelessWidget {
  final String message;
  final int? statusCode;
  final String? title;
  final String? endpoint;
  final String? hint;
  final VoidCallback? onRetry;
  final String heading;

  const ErrorStateView({
    super.key,
    required this.message,
    this.statusCode,
    this.title,
    this.endpoint,
    this.hint,
    this.onRetry,
    this.heading = 'No se pudo cargar el dashboard',
  });

  static String? hintForApiException(ApiException error) =>
      _hintForStatus(error.statusCode, error.endpoint);

  factory ErrorStateView.fromException(
    Object error, {
    String? hint,
    VoidCallback? onRetry,
  }) {
    if (error is ApiException) {
      return ErrorStateView(
        message: error.message,
        statusCode: error.statusCode,
        title: error.title,
        endpoint: error.endpoint,
        hint: hint ?? hintForApiException(error),
        onRetry: onRetry,
      );
    }
    return ErrorStateView(
      message: error.toString(),
      onRetry: onRetry,
    );
  }

  static String? _hintForStatus(int? statusCode, String? endpoint) {
    if (statusCode == 500 && endpoint != null && endpoint.contains('remittances')) {
      return 'El servicio Ledger respondió con error interno. Suele deberse a que '
          'las migraciones de base de datos no se ejecutaron (tabla "remittances" '
          'inexistente). Revisa los logs de ledger-service con: docker logs ledger-service';
    }
    if (statusCode == 401 && endpoint != null && endpoint.contains('login')) {
      return 'El gateway rechazó la solicitud antes de validar credenciales. '
          'Si tenías una sesión anterior, cierra la app y vuelve a intentar. '
          'Si el problema persiste, verifica usuario y contraseña.';
    }
    if (statusCode == 401) {
      return 'Tu sesión expiró. Cierra sesión e inicia de nuevo.';
    }
    if (statusCode == 503) {
      return 'Un microservicio no está disponible. Verifica que Ledger y Web3 estén levantados.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              heading,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark,
                    height: 1.4,
                  ),
            ),
            if (statusCode != null || title != null) ...[
              const SizedBox(height: 12),
              Text(
                [
                  if (statusCode != null) 'HTTP $statusCode',
                  if (title != null) title,
                ].join(' · '),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            if (endpoint != null && endpoint!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                endpoint!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            if (hint != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  hint!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
