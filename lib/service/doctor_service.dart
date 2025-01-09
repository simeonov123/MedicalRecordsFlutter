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
}
