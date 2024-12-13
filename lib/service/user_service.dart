// lib/service/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Fetch all users
  Future<List<User>> fetchAllUsers() async { // Removed accessToken parameter
    final response = await _apiService.get('/users');

    if (response.statusCode == 200) {
      List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Update user role
  Future<bool> updateUserRole(int userId, String role) async { // Adjusted parameters
    final response = await _apiService.put('/users/$userId/role', body: {'role': role});

    return response.statusCode == 200;
  }
}
