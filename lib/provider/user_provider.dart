// lib/provider/user_provider.dart

import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../domain/user.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all users
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.fetchAllUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user role
  Future<bool> updateUserRole(int userId, String role) async {
    bool success = await _userService.updateUserRole(userId, role);
    if (success) {
      // Update local state
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index].role = role;
        notifyListeners();
      }
    }
    return success;
  }
}
