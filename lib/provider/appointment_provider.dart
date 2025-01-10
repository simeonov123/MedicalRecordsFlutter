// lib/provider/appointment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';
import '../domain/appointment.dart';
import '../service/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch appointments for the currently logged-in patient
  Future<List<Appointment>> fetchAppointmentsForUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appointments = await _appointmentService.fetchAppointmentsForUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _appointments;
  }

  // Create an appointment
  Future<bool> createAppointment({
    required int patientId,
    required int doctorId,
    required DateTime date,
  }) async {
    try {
      final apt = await _appointmentService.createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        date: date,
      );
      // Optionally add to local list
      _appointments.add(apt);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<void> createSickLeave(int appointmentId, Map<String, dynamic> sickLeaveData) async {
    await _appointmentService.createSickLeave(appointmentId, sickLeaveData);
    await fetchAppointmentsForUser();
  }

  Future<SickLeave> updateSickLeave(int appointmentId, int sickLeaveId, Map<String, dynamic> sickLeaveData) async {
    try {
      SickLeave updatedFetchedSickLeave = await _appointmentService.updateSickLeave(appointmentId, sickLeaveId, sickLeaveData);

      // Find the matching appointment
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);

      // Find the index of the sick leave to be updated
      final sickLeaveIndex = appointment.sickLeaves.indexWhere((s) => s.id == sickLeaveId);

      if (sickLeaveIndex != -1) {
        // Replace the old sick leave with the updated one
        appointment.sickLeaves[sickLeaveIndex] = updatedFetchedSickLeave;
      } else {

        return updatedFetchedSickLeave;
      }

      // Notify listeners to update the UI
      notifyListeners();

      return updatedFetchedSickLeave;
    } catch (e) {
      // Handle any errors that occur

      return SickLeave(
        id: -1,
        reason: '',
        todayDate: DateTime.now(),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> createDiagnosis(int appointmentId, Map<String, dynamic> diagnosisData) async {
    await _appointmentService.createDiagnosis(appointmentId, diagnosisData);
    await fetchAppointmentsForUser();
  }

  Future<void> updateDiagnosis(int appointmentId, int diagnosisId, Map<String, dynamic> diagnosisData) async {
    await _appointmentService.updateDiagnosis(appointmentId, diagnosisId, diagnosisData);
    await fetchAppointmentsForUser();
  }
}
