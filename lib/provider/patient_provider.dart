// lib/provider/patient_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
    notifyListenersSafely();
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
        notifyListenersSafely();
      }
      return true;
    }
    return false;
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListenersSafely();

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
      notifyListenersSafely();
    }
  }

  void notifyListenersSafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }


  Future<bool> updatePatient(Patient patient) async {
    // The typical endpoint: PUT /patients/{id}
    try {
      final updated = await _apiService.put(
        '/patients/${patient.keycloakUserId}',
        body: {
          "name": patient.name,
          "healthInsurancePaid": patient.healthInsurancePaid,
          "primaryDoctorId": patient.primaryDoctorId, // or null
        },
      );
      if (updated.statusCode == 200) {
        final jsonData = json.decode(updated.body);
        final updatedP = Patient.fromJson(jsonData);
        final index = _patients.indexWhere((p) => p.id == updatedP.id);
        if (index != -1) {
          _patients[index] = updatedP;
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Update failed with code ${updated.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

}