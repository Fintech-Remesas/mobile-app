import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  static const _publicPaths = {
    '/api/v1/users/register',
    '/api/v1/users/login',
    '/api/v1/users/password-recovery/request',
    '/api/v1/users/password-recovery/reset',
  };

  ApiClient({
    required this.dio,
    required this.tokenStorage,
  }) {
    dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = const Duration(milliseconds: ApiConfig.connectTimeoutMs)
      ..receiveTimeout = const Duration(milliseconds: ApiConfig.receiveTimeoutMs)
      ..headers = {'Content-Type': 'application/json'};

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
        onError: (error, handler) {
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
}
