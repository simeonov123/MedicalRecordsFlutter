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

  // Fetch users
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
  Future<bool> updateUserRole(String userId, String role) async {
    bool success = await _userService.updateUserRole(userId, role);
    if (success) {
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index].role = role;
        notifyListeners();
      }
    }
    return success;
  }

  // Verify user email
  Future<bool> verifyUserEmail(String userId, bool verified) async {
    bool success = await _userService.verifyUserEmail(userId, verified);
    if (success) {
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index].emailVerified = verified;
        notifyListeners();
      }
    }
    return success;
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    bool success = await _userService.deleteUser(userId);
    if (success) {
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    }
    return success;
  }

  // Update user details
  Future<bool> updateUserDetails(
      String userId, {
        required String email,
        required String firstName,
        required String lastName,
        required String username,
        required bool emailVerified,
        required String egn,

      }) async {
    bool success = await _userService.updateUserDetails(
      userId, email, firstName, lastName, emailVerified, egn,
    );
    if (success) {
      int index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index].email = email;
        _users[index].username = username;
        _users[index].emailVerified = emailVerified;
        notifyListeners();
      }
    }
    return success;
  }


  /// Call POST /auth/sync to trigger the Keycloak->Local DB sync on the backend
  Future<bool> syncKeycloakUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1) Await the future result from the service
      final bool success = await _userService.syncKeycloakUsers();

      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // 2) If not successful, set an error message
        _error = 'Failed to sync Keycloak users.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // New method: update local user
  Future<bool> updateLocalUser({
    required String userId,
    required String egn,
    required String email,
    required String firstName,
    required String lastName,
    required bool emailVerified,
  }) async {
    final success = await _userService.updateUserDetails(
      userId,
      email,
      firstName,
      lastName,
      emailVerified,
      egn,

    );
    if (success) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          email: email,
          firstName: firstName,
          lastName: lastName,
          emailVerified: emailVerified,
          egn: egn,
        );
        notifyListeners();
      }
    }
    return success;
  }
}
