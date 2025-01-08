// lib/provider/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../service/api_authentication_service.dart';
import 'dart:async'; // Import for Timer

class AuthProvider with ChangeNotifier {
  final ApiAuthenticationService _authService = ApiAuthenticationService();
  bool _isAuthenticated = false;
  String? _accessToken;
  List<String> _roles = [];
  DateTime? _expiryDate;
  Timer? _refreshTimer;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  List<String> get roles => _roles;

  get keycloakUserId => getUserId();

  // Login method
  Future<bool> login(String username, String password) async {
    bool success = await _authService.login(username, password);
    if (success) {
      _accessToken = await _authService.getAccessToken();
      _roles = _accessToken != null ? _extractRoles(_accessToken!) : [];
      _isAuthenticated = true;
      _expiryDate = _accessToken != null ? JwtDecoder.getExpirationDate(_accessToken!) : null;
      notifyListeners();
      _scheduleTokenRefresh();
    }
    return success;
  }

  // Extract roles from JWT token
  List<String> _extractRoles(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    if (decodedToken.containsKey('realm_access')) {
      List<dynamic> roles = decodedToken['realm_access']['roles'];
      return roles.cast<String>();
    }
    return [];
  }

  // Logout method
  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _accessToken = null;
    _roles = [];
    _expiryDate = null;
    _refreshTimer?.cancel();
    notifyListeners();
  }

  // Schedule token refresh before it expires
  void _scheduleTokenRefresh() {
    if (_expiryDate == null) return;

    final timeToExpiry = _expiryDate!.difference(DateTime.now());
    // Refresh 1 minute before expiry
    final refreshDuration = timeToExpiry - const Duration(minutes: 1);

    if (refreshDuration.isNegative) {
      // Token already expired
      logout();
      return;
    }

    _refreshTimer = Timer(refreshDuration, () async {
      bool refreshed = await _authService.refreshAccessToken();
      if (refreshed) {
        _accessToken = await _authService.getAccessToken();
        _roles = _accessToken != null ? _extractRoles(_accessToken!) : [];
        _expiryDate = _accessToken != null ? JwtDecoder.getExpirationDate(_accessToken!) : null;
        notifyListeners();
        _scheduleTokenRefresh();
      } else {
        logout();
      }
    });
  }

  String? getUserId() {
    if (_accessToken != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
      return decodedToken['sub']; // Keycloak typically uses 'sub' for user ID.
    }
    return null;
  }


}
