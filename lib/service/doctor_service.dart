// lib/service/doctor_service.dart

import 'dart:convert';
import '../domain/appointment.dart';
import '../domain/doctor.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  // Fetch all doctors
  Future<List<Doctor>> fetchDoctors() async {
    final response = await _apiService.get('/doctors');
    if (response.statusCode == 200) {
      List<dynamic> doctorsJson = json.decode(response.body);
      return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // Fetch doctor by Keycloak User ID
  Future<Doctor> fetchDoctorByKeycloakId() async {
    final response = await _apiService.get('/doctors/doctor');
    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch doctor details');
    }
  }

  Future<Doctor> updateDoctor(Doctor doc) async {
    // For example, PUT /doctors/{id} with the new data
    final response = await _apiService.put(
      '/doctors/${doc.id}',
      body: {
        "keycloakUserId": doc.keycloakUserId,
        "name": doc.name,
        "specialties": doc.specialties.isEmpty ? "N/A" : doc.specialties,
        "primaryCare": doc.primaryCare,
      },
    );
    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update doctor: ${response.statusCode}');
    }
  }

  // New method: Update doctor by Keycloak User ID
  Future<Doctor> updateDoctorByKeycloakId(Doctor doc) async {
    final response = await _apiService.put(
      '/doctors/${doc.keycloakUserId}',
      body: {
        "primaryCare": doc.primaryCare,
        "specialties": doc.specialties.isEmpty ? "N/A" : doc.specialties,
      },
    );
    if (response.statusCode == 200) {
      return Doctor.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update doctor: ${response.statusCode}');
    }
  }
}
