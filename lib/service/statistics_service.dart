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
    final response = await _apiService.get('/patients/searchByDiagnosis?diagnosis=$diagnosis');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => Patient.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch patients by diagnosis');
    }
  }

  Future<DiagnosisStatisticsDto> fetchDiagnosisLeaderboard() async {
    // Calls GET /statistics/diagnoses/leaderboard
    final response = await _apiService.get('/statistics/diagnoses/leaderboard');
    if (response.statusCode == 200) {
      return DiagnosisStatisticsDto.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception(
        'Failed to fetch diagnosis leaderboard: ${response.statusCode}',
      );
    }
  }

  Future<List<Patient>> fetchPatientsByDoctorId(int doctorId) async {
    final response = await _apiService.get('/statistics/patients/byDoctor/$doctorId');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => Patient.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch patients by doctor ID');
    }
  }


}

// You also need these model classes to parse the JSON above:

class DiagnosisStatisticsDto {
  final List<DiagnosisDetailsDto> diagnosisDetails;

  DiagnosisStatisticsDto({required this.diagnosisDetails});

  factory DiagnosisStatisticsDto.fromJson(Map<String, dynamic> json) {
    final detailsList = (json['diagnosisDetails'] as List)
        .map((item) => DiagnosisDetailsDto.fromJson(item))
        .toList();
    return DiagnosisStatisticsDto(diagnosisDetails: detailsList);
  }
}

class DiagnosisDetailsDto {
  final String statement;
  final int count;
  final int percentageOfAllDiagnoses;
  final int percentageOfAllPatients;
  final String? doctorNameOfFirstDiagnosis;
  final DateTime? dateOfFirstDiagnosis;
  final DateTime? dateOfLastDiagnosis;

  DiagnosisDetailsDto({
    required this.statement,
    required this.count,
    required this.percentageOfAllDiagnoses,
    required this.percentageOfAllPatients,
    required this.doctorNameOfFirstDiagnosis,
    required this.dateOfFirstDiagnosis,
    required this.dateOfLastDiagnosis,
  });

  factory DiagnosisDetailsDto.fromJson(Map<String, dynamic> json) {
    return DiagnosisDetailsDto(
      statement: json['statement'],
      count: json['count'],
      percentageOfAllDiagnoses: json['percentageOfAllDiagnoses'],
      percentageOfAllPatients: json['percentageOfAllPatients'],
      doctorNameOfFirstDiagnosis: json['doctorNameOfFirstDiagnosis'],
      dateOfFirstDiagnosis: json['dateOfFirstDiagnosis'] != null
          ? DateTime.parse(json['dateOfFirstDiagnosis'])
          : null,
      dateOfLastDiagnosis: json['dateOfLastDiagnosis'] != null
          ? DateTime.parse(json['dateOfLastDiagnosis'])
          : null,
    );
  }



}