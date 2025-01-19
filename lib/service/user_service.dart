// lib/service/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // GET /users
  Future<List<User>> fetchAllUsers() async {
    final response = await _apiService.get('/users');
    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((jsonData) => User.fromJson(jsonData)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // PUT /users/{userId}/role { role: "doctor" }
  Future<bool> updateUserRole(String userId, String newRole) async {
    final response = await _apiService.put(
      '/users/$userId/role',
      body: {'role': newRole},
    );
    return response.statusCode == 200;
  }

  // PUT /users/{userId}/verify-email?verified=true/false
  Future<bool> verifyUserEmail(String userId, bool verified) async {
    final response = await _apiService.put(
      '/users/$userId/verify-email?verified=$verified',
    );
    return response.statusCode == 200;
  }

  // DELETE /users/{userId}
  Future<bool> deleteUser(String userId) async {
    final resp = await _apiService.delete('/users/$userId');
    return resp.statusCode == 204;
  }

  // PUT /users/{userId}/details
  Future<bool> updateUserDetails(
      String userId,
      String email,
      String firstName,
      String lastName,
      bool emailVerified,
      String egn,
      ) async {
    final body = {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'egn' : egn,
      'emailVerified': emailVerified,
    };
    final resp = await _apiService.put('/users/$userId/details', body: body);
    return resp.statusCode == 200;
  }

  Future<bool> syncKeycloakUsers() async {
    // Make POST /auth/sync, which returns status code 200 and body "Sync started"
    final resp = await _apiService.post('/auth/sync');

    // If the request was successful (200), return true, else false
    return resp.statusCode == 200;
  }
}
