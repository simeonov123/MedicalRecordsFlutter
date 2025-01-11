// lib/service/appointment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_records_frontend/domain/diagnosis.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';
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


  // Create new sick leave
  Future<void> createSickLeave(int appointmentId, Map<String, dynamic> sickLeaveData) async {
    final response = await _apiService.post('/appointments/$appointmentId/sick-leave', body: sickLeaveData);
    if (response.statusCode != 200) {
      throw Exception('Failed to create sick leave');
    }
  }

  // Update existing sick leave
  Future<SickLeave> updateSickLeave(int appointmentId, int sickLeaveId, Map<String, dynamic> sickLeaveData) async {
    final response = await _apiService.put('/appointments/$appointmentId/sick-leave/$sickLeaveId', body: sickLeaveData);
    if (response.statusCode != 200) {
      throw Exception('Failed to update sick leave');
    }else{
      return SickLeave.fromJson(json.decode(response.body));
    }
  }

  // Delete sick leave
  Future<bool> deleteSickLeave(int appointmentId, int sickLeaveId) async {
    final response = await _apiService.delete('/appointments/$appointmentId/sick-leave/$sickLeaveId');
    return response.statusCode == 204;
  }

  // Create new diagnosis
  Future<void> createDiagnosis(int appointmentId, Map<String, dynamic> diagnosisData) async {
    final response = await _apiService.post('/appointments/$appointmentId/diagnosis', body: diagnosisData);
    if (response.statusCode != 200) {
      throw Exception('Failed to create diagnosis');
    }
  }

  // Update existing diagnosis
  Future<Diagnosis> updateDiagnosis(int appointmentId, int diagnosisId, Map<String, dynamic> diagnosisData) async {
    final response = await _apiService.put('/appointments/$appointmentId/diagnosis/$diagnosisId', body: diagnosisData);
    if (response.statusCode != 200) {
      throw Exception('Failed to update diagnosis');
    }else{
      return Diagnosis.fromJson(json.decode(response.body));
    }
  }

  Future<bool> deleteDiagnosis(int appointmentId, int diagnosisId) async {
    final response = await _apiService.delete('/appointments/$appointmentId/diagnosis/$diagnosisId');
    return response.statusCode == 204;
  }

  Future<Appointment> updateAppointment(int appointmentId, DateTime date,
      int? doctorId) async {
    final body = {
      if (doctorId != null) "doctorId": doctorId,
      "appointmentDateTime": date.toIso8601String(),
    };
    final response = await _apiService.put(
        '/appointments/$appointmentId', body: body);
    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update appointment');
    }
  }


  // Delete appointment
  Future<bool> deleteAppointment(int appointmentId) async {
    final response = await _apiService.delete('/appointments/$appointmentId');
    return response.statusCode == 204;
  }


  // Fetch all appointments for a specific patient
  Future<List<Appointment>> fetchAllAppointmentsForPatient(int patientId) async {
    final response = await _apiService.get('/appointments/$patientId/appointments');
    if (response.statusCode == 200) {
      List<dynamic> listJson = json.decode(response.body);
      return listJson.map((j) => Appointment.fromJson(j)).toList();
    } else {
      throw Exception('Failed to fetch appointments for patient');
    }
  }
}