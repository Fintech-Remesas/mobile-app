import 'package:dio/dio.dart';

import '../auth/auth_refresh_notifier.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;
  final AuthRefreshNotifier authRefreshNotifier;

  static const _publicPaths = {
    '/api/v1/users/register',
    '/api/v1/users/login',
    '/api/v1/users/password-recovery/request',
    '/api/v1/users/password-recovery/reset',
    '/api/v1/health',
  };

  ApiClient({
    required this.dio,
    required this.tokenStorage,
    AuthRefreshNotifier? notifier,
  }) : authRefreshNotifier = notifier ?? AuthRefreshNotifier() {
    dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = const Duration(milliseconds: ApiConfig.connectTimeoutMs)
      ..receiveTimeout = const Duration(milliseconds: ApiConfig.receiveTimeoutMs)
      ..headers = {'Content-Type': 'application/json'};
    dio.options.validateStatus = (status) =>
        status != null && status >= 200 && status < 300;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.uri.path;
          final isPublic = _publicPaths.contains(path);

          if (!isPublic) {
            final token = await tokenStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.uri.path;
            if (!_publicPaths.contains(path)) {
              await tokenStorage.clearTokens();
              authRefreshNotifier.notifySessionExpired();
            }
          }
          handler.reject(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await dio.delete<T>(path);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
