// lib/provider/medication_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../service/medication_service.dart';
import '../domain/medication.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationService _medicationService = MedicationService();
  List<Medication> _medications = [];
  bool _isLoading = false;
  String? _error;

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMedications() async {
    _isLoading = true;
    notifyListenersSafely();

    try {
      _medications = await _medicationService.fetchMedications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  void notifyListenersSafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}