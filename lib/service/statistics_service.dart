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

  Future<List<DoctorPatientCount>> fetchDoctorsWithPatientCount() async {
    final response = await _apiService.get('/statistics/doctors-with-patient-count');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => DoctorPatientCount.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch doctors with patient count');
    }
  }

  Future<List<DoctorAppointmentCount>> fetchDoctorsWithAppointmentsCount() async {
    final response = await _apiService.get('/statistics/doctors-with-appointments-count');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => DoctorAppointmentCount.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch doctors with appointments count');
    }
  }



  fetchDoctorsThatHaveAppointmentsInAPeriod(DateTime startDate, DateTime endDate) async {
    final response = await _apiService.get('/statistics/doctors-with-appointments-in-period?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => DoctorsThatHaveAppointmentsInPeriod.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch doctors with appointments count');
    }

  }

  Future<List<MostSickLeavesMonthData>> fetchMonthDataFromBackend() async {
    final response = await _apiService.get('/statistics/most-sick-leaves-month-data');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = [MostSickLeavesMonthData.fromJson(jsonResponse)];
      return data;
    } else {
      throw Exception('Failed to fetch most sick leaves month data');
    }
  }

  Future<List<DoctorsSickLeavesLeaderboardDto>> fetchDoctorsSickLeavesLeaderboard() async {
    final response = await _apiService.get('/statistics/doctors-sick-leaves-leaderboard');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => DoctorsSickLeavesLeaderboardDto.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to fetch doctors sick leaves leaderboard');
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


// DTO for the data from this method in the StatisticsService: fetchDoctorsWithPatientCount()
class DoctorPatientCount {
  final String doctorName;
  final int count;

  DoctorPatientCount({required this.doctorName, required this.count});

  factory DoctorPatientCount.fromJson(Map<String, dynamic> json) {
    return DoctorPatientCount(
      doctorName: json['doctorName'],
      count: json['count'],
    );
  }
}

class DoctorAppointmentCount {
  final String doctorName;
  final int count;

  DoctorAppointmentCount({required this.doctorName, required this.count});

  factory DoctorAppointmentCount.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentCount(
      doctorName: json['doctorName'],
      count: json['count'],
    );
  }
}


class DoctorsThatHaveAppointmentsInPeriod {
  final String doctorName;
  final int doctorId;
  final DateTime startDate;
  final DateTime endDate;

  DoctorsThatHaveAppointmentsInPeriod({
    required this.doctorName,
    required this.doctorId,
    required this.startDate,
    required this.endDate,
  });

  factory DoctorsThatHaveAppointmentsInPeriod.fromJson(Map<String, dynamic> json) {
    return DoctorsThatHaveAppointmentsInPeriod(
      doctorName: json['doctorName'],
      doctorId: json['doctorId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}


class MostSickLeavesMonthData {
  final String monthName;
  final int sickLeavesCount;
  final int appointmentsThatMonthCount;
  final int uniquePatientsCount;
  final String mostCommonDiagnosisThatMonth;

  MostSickLeavesMonthData({
    required this.monthName,
    required this.sickLeavesCount,
    required this.appointmentsThatMonthCount,
    required this.uniquePatientsCount,
    required this.mostCommonDiagnosisThatMonth,
  });

  factory MostSickLeavesMonthData.fromJson(Map<String, dynamic> json) {
    return MostSickLeavesMonthData(
      monthName: json['monthName'],
      sickLeavesCount: json['sickLeavesCount'],
      appointmentsThatMonthCount: json['appointmentsThatMonthCount'],
      uniquePatientsCount: json['uniquePatientsCount'],
      mostCommonDiagnosisThatMonth: json['mostCommonDiagnosisThatMonth'],
    );
  }

  @override
  String toString() {
    return 'MostSickLeavesMonthData(monthName: $monthName, sickLeavesCount: $sickLeavesCount, appointmentsThatMonthCount: $appointmentsThatMonthCount, uniquePatientsCount: $uniquePatientsCount, mostCommonDiagnosisThatMonth: $mostCommonDiagnosisThatMonth)';
  }
}


class DoctorsSickLeavesLeaderboardDto {
  final String name;
  final String specialties;
  final bool primaryCare;
  final int sickLeavesCount;

  DoctorsSickLeavesLeaderboardDto({
    required this.name,
    required this.specialties,
    required this.primaryCare,
    required this.sickLeavesCount,
  });

  factory DoctorsSickLeavesLeaderboardDto.fromJson(Map<String, dynamic> json) {
    return DoctorsSickLeavesLeaderboardDto(
      name: json['name'],
      specialties: json['specialties'],
      primaryCare: json['primaryCare'],
      sickLeavesCount: json['sickLeavesCount'],
    );
  }
}

