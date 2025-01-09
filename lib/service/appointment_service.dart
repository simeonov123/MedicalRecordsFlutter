// lib/service/appointment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/appointment.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _apiService = ApiService();

  // GET /appointments? -> typically for doctors or admin
  // but if you only want for the current patient, you might have a custom route
  // or we can do the filtering server-side or pass the patientId to an endpoint.

  // For a simpler approach, you might define an endpoint: GET /patients/{patientId}/appointments
  // Then call that from here:

  Future<List<Appointment>> fetchAppointmentsForUser() async {

    final response = await _apiService.get('/appointments/getAppointmentsForLoggedInUser');
    if (response.statusCode == 200) {
      List<dynamic> listJson = json.decode(response.body);
      return listJson.map((j) => Appointment.fromJson(j)).toList();
    } else {
      throw Exception('Failed to fetch appointments for patient');
    }
  }

  // Create new appointment POST /appointments
  Future<Appointment> createAppointment({
    required int patientId,
    required int doctorId,
    required DateTime date,
  }) async {
    final body = {
      "patientId": patientId,
      "doctorId": doctorId,
      "date": date.toIso8601String(),
    };
    final response = await _apiService.post('/appointments', body: body);
    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create appointment');
    }
  }
}
