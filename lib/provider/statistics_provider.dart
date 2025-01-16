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

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalAppointments => _totalAppointments;
  List<String> get uniqueDiagnoses => _uniqueDiagnoses;
  List<Patient> get queriedPatients => _queriedPatients;


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
}