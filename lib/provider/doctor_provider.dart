// lib/provider/doctor_provider.dart

import 'package:flutter/material.dart';
import '../service/doctor_service.dart';
import '../domain/doctor.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _error;

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch doctors
  Future<void> fetchDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _doctors = await _doctorService.fetchDoctors();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

// Add more methods as needed
}
