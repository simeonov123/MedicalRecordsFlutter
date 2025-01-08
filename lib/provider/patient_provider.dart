// lib/provider/patient_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/patient.dart';
import '../service/api_service.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Patient> _patients = [];
  Patient? _patient;
  bool _isLoading = false;
  String? _error;

  Patient? get patient => _patient;

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> assignPrimaryDoctor(int patientId, int doctorId) async {
    final resp = await _apiService.put('/patients/$patientId/primary-doctor/$doctorId');
    return resp.statusCode == 200;
  }

  Future<Patient?> fetchPatientDataViaKeycloakUserId(String keycloakUserId) async {
    final response = await _apiService.get('/patients/keycloak-user-id/$keycloakUserId');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      _patient = Patient.fromJson(jsonData);
      _error = null;
    } else {
      _error = 'Failed to load patient';
    }
    notifyListeners();
    return _patient;
  }


  Future<bool> updateHealthInsuranceStatus(int patientId, bool status) async {
    final resp = await _apiService.put('/patients/$patientId/health-insurance', body: {'healthInsurancePaid': status});
    if (resp.statusCode == 200) {
      final index = _patients.indexWhere((patient) => patient.id == patientId);
      if (index != -1) {
        _patients[index] = Patient(
          id: _patients[index].id,
          name: _patients[index].name,
          egn: _patients[index].egn,
          healthInsurancePaid: status,
          primaryDoctorId: _patients[index].primaryDoctorId,
          keycloakUserId: _patients[index].keycloakUserId,
        );
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/patients');
      if (response.statusCode == 200) {
        List<dynamic> listJson = json.decode(response.body);
        _patients = listJson.map((jsonData) => Patient.fromJson(jsonData)).toList();
        _error = null;
      } else {
        _error = 'Failed to load patients';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  getPatient() {}
}