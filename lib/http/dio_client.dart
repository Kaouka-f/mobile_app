import 'package:dio/dio.dart';

Dio buildDio({
  required String baseUrl,
  String? token,
  Duration connectTimeout = const Duration(seconds: 5),
  Duration receiveTimeout = const Duration(seconds: 15),
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
