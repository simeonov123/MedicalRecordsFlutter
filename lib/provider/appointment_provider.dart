// lib/provider/appointment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';
import '../domain/appointment.dart';
import '../domain/diagnosis.dart';
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


  Future<void> createSickLeave(int appointmentId,
      Map<String, dynamic> sickLeaveData) async {
    await _appointmentService.createSickLeave(appointmentId, sickLeaveData);
    await fetchAppointmentsForUser();
  }

  Future<SickLeave> updateSickLeave(int appointmentId, int sickLeaveId,
      Map<String, dynamic> sickLeaveData) async {
    try {
      SickLeave updatedFetchedSickLeave = await _appointmentService
          .updateSickLeave(appointmentId, sickLeaveId, sickLeaveData);

      // Find the matching appointment
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);

      // Find the index of the sick leave to be updated
      final sickLeaveIndex = appointment.sickLeaves.indexWhere((s) =>
      s.id == sickLeaveId);

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

  // Delete sick leave
  Future<bool> deleteSickLeave(int appointmentId, int sickLeaveId) async {
    bool success = await _appointmentService.deleteSickLeave(
        appointmentId, sickLeaveId);
    if (success) {
      final appointmentIndex = _appointments.indexWhere((
          appointment) => appointment.id == appointmentId);
      if (appointmentIndex != -1) {
        _appointments[appointmentIndex].sickLeaves.removeWhere((
            sickLeave) => sickLeave.id == sickLeaveId);
        notifyListeners();
      }
    }
    return success;
  }


  Future<void> createDiagnosis(int appointmentId,
      Map<String, dynamic> diagnosisData) async {
    await _appointmentService.createDiagnosis(appointmentId, diagnosisData);
    await fetchAppointmentsForUser();
  }

  Future<Diagnosis> updateDiagnosis(int appointmentId, int diagnosisId,
      Map<String, dynamic> diagnosisData) async {
    try {
      Diagnosis updatedFetchedDiagnosis = await _appointmentService
          .updateDiagnosis(appointmentId, diagnosisId, diagnosisData);

      // Find the matching appointment
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);

      // Find the index of the diagnosis to be updated
      final diagnosisIndex = appointment.diagnoses.indexWhere((d) =>
      d.id == diagnosisId);

      if (diagnosisIndex != -1) {
        // Replace the old diagnosis with the updated one
        appointment.diagnoses[diagnosisIndex] = updatedFetchedDiagnosis;
      } else {
        return updatedFetchedDiagnosis;
      }

      // Notify listeners to update the UI
      notifyListeners();

      return updatedFetchedDiagnosis;
    } catch (e) {
      // Handle any errors that occur
      return Diagnosis(
        id: -1,
        statement: '',
        diagnosedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        treatments: [],
      );
    }
  }

  Future<bool> deleteDiagnosis(int appointmentId, int diagnosisId) async {
    bool success = await _appointmentService.deleteDiagnosis(
        appointmentId, diagnosisId);
    if (success) {
      int appointmentIndex = _appointments.indexWhere((
          appointment) => appointment.id == appointmentId);
      if (appointmentIndex != -1) {
        _appointments[appointmentIndex].diagnoses.removeWhere((
            diagnosis) => diagnosis.id == diagnosisId);
        notifyListeners();
      }
    }
    return success;
  }


  Future<Appointment> updateAppointment(int appointmentId, DateTime date,
      int? doctorId) async {
    final updatedAppointment = await _appointmentService.updateAppointment(
        appointmentId, date, doctorId);
    int index = _appointments.indexWhere((appointment) =>
    appointment.id == appointmentId);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListeners();
    }
    return updatedAppointment;
  }

  void updateLocalAppointment(Appointment updatedAppointment) {
    int index = _appointments.indexWhere((appointment) =>
    appointment.id == updatedAppointment.id);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListeners();
    }
  }
}