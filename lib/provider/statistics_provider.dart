import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../service/statistics_service.dart';
import '../domain/patient.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();
  bool _isLoading = false;
  String? _error;
  int _totalAppointments = 0;
  List<String> _uniqueDiagnoses = [];
  List<Patient> _queriedPatients = [];
  List<Patient> _patientsByDoctor = [];
  List<Patient> get patientsByDoctor => _patientsByDoctor;
  List<DiagnosisDetailsDto> _diagnosisLeaderboard = [];
  List<DoctorPatientCount> _doctorsPatientCount = [];
  List<DoctorAppointmentCount> _doctorsAppointmentCount = [];
  List<DoctorsThatHaveAppointmentsInPeriod> _doctorsThatHaveAppointmentsInPeriod = [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalAppointments => _totalAppointments;
  List<String> get uniqueDiagnoses => _uniqueDiagnoses;
  List<Patient> get queriedPatients => _queriedPatients;
  List<DiagnosisDetailsDto> get diagnosisLeaderboard => _diagnosisLeaderboard;
  List<DoctorPatientCount> get doctorsPatientCount => _doctorsPatientCount;
  List<DoctorAppointmentCount> get doctorsAppointmentCount => _doctorsAppointmentCount;
  List<DoctorsThatHaveAppointmentsInPeriod> get doctorsThatHaveAppointmentsInPeriod => _doctorsThatHaveAppointmentsInPeriod;



  void notifyListenersSafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }


  Future<void> fetchStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _totalAppointments = await _statisticsService.getTotalAppointments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  Future<void> fetchAllUniqueDiagnoses() async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _uniqueDiagnoses = await _statisticsService.fetchAllUniqueDiagnoses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  Future<void> fetchQueriedPatientsByDiagnosis(String diagnosis) async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _queriedPatients = await _statisticsService.fetchQueriedPatientsByDiagnosis(diagnosis);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }


  // 4) **New** fetchDiagnosisLeaderboard
  Future<void> fetchDiagnosisLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      final dto = await _statisticsService.fetchDiagnosisLeaderboard();
      // Store only top 10 for display
      _diagnosisLeaderboard = dto.diagnosisDetails.take(10).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }



  Future<void> fetchPatientsByDoctorId(int doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _patientsByDoctor = await _statisticsService.fetchPatientsByDoctorId(doctorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }



  Future<void> fetchDoctorsWithPatientCount() async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _doctorsPatientCount = await _statisticsService.fetchDoctorsWithPatientCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }


  Future<void> fetchDoctorsWithAppointmentsCount() async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _doctorsAppointmentCount = await _statisticsService.fetchDoctorsWithAppointmentsCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  Future<void> fetchDoctorsThatHaveAppointmentsInAPeriod(DateTime? startDate, DateTime? endDate ) async {
    _isLoading = true;
    _error = null;
    notifyListenersSafely();

    try {
      _doctorsThatHaveAppointmentsInPeriod = await _statisticsService.fetchDoctorsThatHaveAppointmentsInAPeriod( startDate!, endDate!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }
}