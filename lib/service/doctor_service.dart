// lib/service/doctor_service.dart

import 'dart:convert';
import '../domain/doctor.dart';
import 'api_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();

  // Fetch doctors
  Future<List<Doctor>> fetchDoctors() async {
    final response = await _apiService.get('/doctors');

    if (response.statusCode == 200) {
      List<dynamic> doctorsJson = json.decode(response.body);
      return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

// Add more doctor-related API methods as needed
}
