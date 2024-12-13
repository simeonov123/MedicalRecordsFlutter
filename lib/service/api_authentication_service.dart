// lib/service/api_authentication_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiAuthenticationService {
  final String keycloakUrl = 'http://localhost:8080/realms/medical-realm/protocol/openid-connect';
  final String clientId = 'medical-frontend';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Login method
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$keycloakUrl/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'client_id': clientId,
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
      await storage.write(key: 'refresh_token', value: data['refresh_token']); // Optional: If implementing token refresh
      return true;
    } else {
      // Optionally, parse error response for better error handling
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token'); // If using refresh tokens
    if (accessToken != null) {
      await http.post(
        Uri.parse('$keycloakUrl/logout'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'refresh_token': refreshToken ?? '',
        },
      );
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token'); // If using refresh tokens
    }
  }

  // Retrieve Access Token
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // Retrieve Refresh Token (if implementing token refresh)
  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  // Signup method (Placeholder)
  Future<bool> signup(String username, String email, String password) async {
    // Implement user signup via backend API
    // This function should call your backend to create a user in Keycloak
    // For now, return false as a placeholder
    return false;
  }

  // Refresh Access Token (Optional)
  Future<bool> refreshAccessToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$keycloakUrl/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
      if (data.containsKey('refresh_token')) {
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
      }
      return true;
    } else {
      return false;
    }
  }
}
