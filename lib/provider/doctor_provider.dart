// lib/provider/doctor_provider.dart

import 'package:flutter/material.dart';
import '../service/doctor_service.dart';
import '../domain/doctor.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  Doctor? _currentDoctor;
  bool _isLoading = false;
  String? _error;

  List<Doctor> get doctors => _doctors;
  Doctor? get currentDoctor => _currentDoctor;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all doctors
  Future<void> fetchDoctors() async {
    _isLoading = true;
    _notifySafely();

    try {
      _doctors = await _doctorService.fetchDoctors();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // Fetch current doctor by Keycloak User ID
  Future<void> fetchCurrentDoctor() async {
    _isLoading = true;
    _notifySafely();

    try {
      _currentDoctor = await _doctorService.fetchDoctorByKeycloakId();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  // Safe notify method
  void _notifySafely() {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ||
        WidgetsBinding.instance.lifecycleState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Update an existing doctor (specialties, primaryCare, etc.)
  Future<bool> updateDoctor(Doctor doc) async {
    try {
      final updatedDoc = await _doctorService.updateDoctor(doc);
      // locally update
      final index = _doctors.indexWhere((d) => d.id == doc.id);
      if (index != -1) {
        _doctors[index] = updatedDoc;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // New method: Update doctor by Keycloak User ID
  Future<bool> updateDoctorByKeycloakId(Doctor doc) async {
    try {
      final updatedDoc = await _doctorService.updateDoctorByKeycloakId(doc);
      // locally update
      final index = _doctors.indexWhere((d) => d.keycloakUserId == doc.keycloakUserId);
      if (index != -1) {
        _doctors[index] = updatedDoc;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}