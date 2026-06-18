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

  static ApiException fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final data = response?.data;
    final path = error.requestOptions.uri.path;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'] as String?;
      final message = data['message'] as String? ??
          detail ??
          data['error'] as String?;
      final title = data['title'] as String?;
      final instance = data['instance'] as String?;
      final type = data['type'] as String?;

      if (message != null && message.isNotEmpty) {
        return ApiException(
          message,
          statusCode: statusCode ?? (data['status'] as num?)?.toInt(),
          title: title,
          endpoint: instance ?? path,
          type: type,
        );
      }

      if (statusCode == 401) {
        return ApiException(
          'No autorizado (HTTP 401). Verifica tus credenciales.',
          statusCode: 401,
          title: title ?? 'Unauthorized',
          endpoint: path,
        );
      }
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
