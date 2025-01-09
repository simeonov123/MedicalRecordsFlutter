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
    notifyListeners();

    try {
      _doctors = await _doctorService.fetchDoctors();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch current doctor by Keycloak User ID
  Future<void> fetchCurrentDoctor() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentDoctor = await _doctorService.fetchDoctorByKeycloakId();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
