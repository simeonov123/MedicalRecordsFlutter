// lib/service/api_service.dart

import 'package:http/http.dart' as http;
import 'api_authentication_service.dart';
import 'dart:convert'; // Add this import

class ApiService {
  final String backendUrl = 'http://localhost:8081'; // Update if different
  final ApiAuthenticationService _authService = ApiAuthenticationService();

  // GET request
  Future<http.Response> get(String endpoint) async {
    final accessToken = await _authService.getAccessToken();
    return await http.get(
      Uri.parse('$backendUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }

  // POST request
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final accessToken = await _authService.getAccessToken();
    return await http.post(
      Uri.parse('$backendUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body != null ? json.encode(body) : null, // Use json.encode
    );
  }

  // PUT request
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final accessToken = await _authService.getAccessToken();
    return await http.put(
      Uri.parse('$backendUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body != null ? json.encode(body) : null, // Use json.encode
    );
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final accessToken = await _authService.getAccessToken();
    return await http.delete(
      Uri.parse('$backendUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }
}
