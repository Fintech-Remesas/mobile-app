import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? title;
  final String? endpoint;
  final String? type;

  const ApiException(
    this.message, {
    this.statusCode,
    this.title,
    this.endpoint,
    this.type,
  });

  String get displayMessage {
    final buffer = StringBuffer();
    buffer.writeln(message);
    if (title != null && title!.isNotEmpty) {
      buffer.writeln();
      buffer.write('[$title]');
    }
    if (statusCode != null) {
      buffer.write(' HTTP $statusCode');
    }
    if (endpoint != null && endpoint!.isNotEmpty) {
      buffer.writeln();
      buffer.write(endpoint);
    }
    return buffer.toString().trim();
  }

  @override
  String toString() => displayMessage;

  static String _friendlyMessage({
    required String? title,
    required String? detail,
    required String? message,
    required String? error,
    required int? statusCode,
  }) {
    final raw = detail ?? message ?? error;
    if (raw != null && raw.isNotEmpty) return raw;

    if (title != null) {
      switch (title) {
        case 'Duplicate Idempotency Key':
          return 'Esta operación ya fue procesada. Revisa tu historial.';
        case 'Quote Expired':
          return 'La cotización expiró o ya fue usada. Solicita una nueva.';
        case 'Insufficient Funds':
          return 'Fondos insuficientes para completar la operación.';
        case 'Invalid State Transition':
          return 'La remesa no está en un estado válido para esta acción.';
        case 'Quote Not Found':
          return 'La cotización no fue encontrada.';
        case 'Remittance Not Found':
          return 'La remesa no fue encontrada.';
        case 'Validation Failed':
          return 'Datos inválidos. Revisa los campos e intenta de nuevo.';
      }
    }

    if (statusCode == 401) {
      return 'No autorizado. Inicia sesión nuevamente.';
    }
    if (statusCode == 409) {
      return 'Conflicto: la operación ya fue registrada.';
    }
    if (statusCode == 422) {
      return 'No se pudo procesar la solicitud en el estado actual.';
    }

    return 'Error inesperado del servidor.';
  }

  static ApiException fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    final path = error.requestOptions.uri.path;

    if (data is Map<String, dynamic>) {
      final success = data['success'] as bool?;
      if (success == false) {
        final iamMessage = data['message'] as String?;
        if (iamMessage != null && iamMessage.isNotEmpty) {
          return ApiException(
            iamMessage,
            statusCode: statusCode,
            endpoint: path,
          );
        }
      }

      final detail = data['detail'] as String?;
      final message = data['message'] as String?;
      final errorMsg = data['error'] as String?;
      final title = data['title'] as String?;
      final instance = data['instance'] as String?;
      final type = data['type'] as String?;

      final friendly = _friendlyMessage(
        title: title,
        detail: detail,
        message: message,
        error: errorMsg,
        statusCode: statusCode ?? (data['status'] as num?)?.toInt(),
      );

      return ApiException(
        friendly,
        statusCode: statusCode ?? (data['status'] as num?)?.toInt(),
        title: title,
        endpoint: instance ?? path,
        type: type,
      );
    }

    if (data is String && data.isNotEmpty) {
      return ApiException(data, statusCode: statusCode, endpoint: path);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException('La solicitud tardó demasiado. Intenta de nuevo.');
      case DioExceptionType.connectionError:
        return ApiException(
          'No se puede conectar al API Sagiro (${error.requestOptions.baseUrl}). '
          'Verifica que el gateway esté activo y que la baseUrl sea correcta.',
          endpoint: path,
        );
      default:
        return ApiException(
          error.message ?? 'Error de red inesperado',
          statusCode: statusCode,
          endpoint: path,
        );
    }
  }
}
