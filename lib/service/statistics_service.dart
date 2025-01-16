import 'dart:convert';

import 'appointment_service.dart';
import 'api_service.dart';
import '../domain/patient.dart';

class StatisticsService {
  final AppointmentService _appointmentService = AppointmentService();
  final ApiService _apiService = ApiService();

  Future<int> getTotalAppointments() async {
    final appointments = await _appointmentService.fetchAppointmentsForUser();
    return appointments.length;
  }

  Future<List<String>> fetchAllUniqueDiagnoses() async {
    final response = await _apiService.get('/statistics/diagnoses/unique');
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch unique diagnoses');
    }
  }
  Future<List<Patient>> fetchQueriedPatientsByDiagnosis(String diagnosis) async {
    final response = await _apiService.get('/patients?diagnosis=$diagnosis');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => Patient.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch patients by diagnosis');
    }
  }
}