// lib/service/doctor_service.dart

import 'dart:convert';
import '../domain/appointment.dart';
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

  Future<List<Appointment>> fetchAppointmentsForDoctor(
      int doctorId, String startDate, String endDate) async {
    final response = await _apiService.get(
      '/reports/visits-for-doctor-in-period?doctorId=$doctorId&start=$startDate&end=$endDate',
    );
    if (response.statusCode == 200) {
      List<dynamic> appointmentsJson = json.decode(response.body);
      return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch appointments.');
    }
  }
}
