import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response_model.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({
    this.baseUrl = ApiEndpoints.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<ApiResponseModel<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Object?)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.get(uri, headers: headers);

    return _handleResponse<T>(response, fromJson);
  }

  Future<ApiResponseModel<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    T Function(Object?)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse<T>(response, fromJson);
  }

  Future<ApiResponseModel<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    T Function(Object?)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse<T>(response, fromJson);
  }

  ApiResponseModel<T> _handleResponse<T>(
    http.Response response,
    T Function(Object?)? fromJson,
  ) {
    final responseBody = utf8.decode(response.bodyBytes);
    final contentType = response.headers['content-type'] ?? '';

    if (!contentType.toLowerCase().contains('application/json')) {
      final preview = responseBody.length > 120
          ? '${responseBody.substring(0, 120)}...'
          : responseBody;
      throw Exception(
        '서버가 JSON이 아닌 응답을 반환했습니다 '
        '(status: ${response.statusCode}, content-type: $contentType). '
        'API 경로/리버스 프록시 설정을 확인해주세요. 응답 일부: $preview',
      );
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('예상하지 못한 응답 형식입니다. (status: ${response.statusCode})');
    }
    final json = decoded;

    if (fromJson != null && json['data'] != null) {
      json['data'] = fromJson(json['data']);
    }

    return ApiResponseModel.fromJson(json, (json) => json as T);
  }
}

