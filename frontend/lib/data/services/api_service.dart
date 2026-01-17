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

  ApiResponseModel<T> _handleResponse<T>(
    http.Response response,
    T Function(Object?)? fromJson,
  ) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (fromJson != null && json['data'] != null) {
      json['data'] = fromJson(json['data']);
    }

    return ApiResponseModel.fromJson(json, (json) => json as T);
  }
}

