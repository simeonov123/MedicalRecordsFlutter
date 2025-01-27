// lib/provider/appointment_provider.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';
import '../domain/appointment.dart';
import '../domain/diagnosis.dart';
import '../domain/doctor.dart';
import '../domain/medication.dart';
import '../domain/patient.dart';
import '../domain/prescription.dart';
import '../domain/treatment.dart';
import '../service/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;

  bool get isLoading => _isLoading;

  String? get error => _error;

  void notifyListenersSafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Fetch appointments for the currently logged-in patient
  Future<List<Appointment>> fetchAppointmentsForUser() async {
    _isLoading = true;
    debugPrint('fetchAppointmentsForUser: _isLoading set to true');
    notifyListenersSafely();

    try {
      _appointments = await _appointmentService.fetchAppointmentsForUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Defer state update until after the current frame
      notifyListenersSafely();
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
      notifyListenersSafely();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListenersSafely();
      return false;
    }
  }

  Future<bool> createSickLeave(int appointmentId, Map<String, dynamic> sickLeaveData) async {
    try {
      final newSickLeave = await _appointmentService.createSickLeave(appointmentId, sickLeaveData);

      final appointmentIndex = _appointments.indexWhere((a) => a.id == appointmentId);
      if (appointmentIndex == -1) return false;

      _appointments[appointmentIndex].sickLeaves.add(newSickLeave);

      notifyListenersSafely();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListenersSafely();
      return false;
    }
  }

  Future<SickLeave> updateSickLeave(int appointmentId, int sickLeaveId,
      Map<String, dynamic> sickLeaveData) async {
    try {
      SickLeave updatedFetchedSickLeave = await _appointmentService
          .updateSickLeave(appointmentId, sickLeaveId, sickLeaveData);

      // Find the matching appointment
      final appointment = appointments.firstWhere(
        (a) => a.id == appointmentId,
        orElse: () => Appointment(
          id: -1,
          patient: Patient(
            id: -1,
            name: 'Unknown',
            egn: 'N/A',
            healthInsurancePaid: false,
            primaryDoctorId: -1,
            keycloakUserId: 'N/A',
          ),
          doctor: Doctor(
            id: -1,
            keycloakUserId: 'N/A',
            name: 'Unknown',
            specialties: 'N/A',
            primaryCare: false,
          ),
          appointmentDateTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: null,
          sickLeaves: [],
          diagnoses: [],
        ),
      );

      // Find the index of the sick leave to be updated
      final sickLeaveIndex =
          appointment.sickLeaves.indexWhere((s) => s.id == sickLeaveId);

      if (sickLeaveIndex != -1) {
        // Replace the old sick leave with the updated one
        appointment.sickLeaves[sickLeaveIndex] = updatedFetchedSickLeave;
      } else {
        return updatedFetchedSickLeave;
      }

      // Notify listeners to update the UI
      notifyListenersSafely();

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
    bool success =
        await _appointmentService.deleteSickLeave(appointmentId, sickLeaveId);
    if (success) {
      final appointmentIndex = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);
      if (appointmentIndex != -1) {
        _appointments[appointmentIndex]
            .sickLeaves
            .removeWhere((sickLeave) => sickLeave.id == sickLeaveId);
        notifyListenersSafely();
      }
    }
    return success;
  }

  Future<bool> createDiagnosis(int appointmentId, Map<String, dynamic> diagnosisData) async {
    try {
      // 1) Call the service to create the new Diagnosis
      final newDiagnosis = await _appointmentService.createDiagnosis(appointmentId, diagnosisData);

      // 2) Find the relevant appointment in _appointments
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index == -1) {
        // Could handle error or do nothing if appointment not found
        return false;
      }

      // 3) Push the newly created diagnosis into the local list
      _appointments[index].diagnoses.add(newDiagnosis);

      // 4) Notify the UI
      notifyListenersSafely();
      return true;

    } catch (e) {
      _error = e.toString();
      notifyListenersSafely();
      return false;
    }
  }



  Future<Diagnosis> updateDiagnosis(int appointmentId, int diagnosisId,
      Map<String, dynamic> diagnosisData) async {
    try {
      Diagnosis updatedFetchedDiagnosis = await _appointmentService
          .updateDiagnosis(appointmentId, diagnosisId, diagnosisData);

      // Find the matching appointment
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);

      // Find the index of the diagnosis to be updated
      final diagnosisIndex =
          appointment.diagnoses.indexWhere((d) => d.id == diagnosisId);

      if (diagnosisIndex != -1) {
        // Replace the old diagnosis with the updated one
        appointment.diagnoses[diagnosisIndex] = updatedFetchedDiagnosis;
      } else {
        return updatedFetchedDiagnosis;
      }

      // Notify listeners to update the UI
      notifyListenersSafely();

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
    bool success =
        await _appointmentService.deleteDiagnosis(appointmentId, diagnosisId);
    if (success) {
      int appointmentIndex = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);
      if (appointmentIndex != -1) {
        _appointments[appointmentIndex]
            .diagnoses
            .removeWhere((diagnosis) => diagnosis.id == diagnosisId);
        notifyListenersSafely();
      }
    }
    return success;
  }

  Future<Appointment> updateAppointment(
      int appointmentId, DateTime date, int? doctorId) async {
    final updatedAppointment = await _appointmentService.updateAppointment(
        appointmentId, date, doctorId);
    int index = _appointments
        .indexWhere((appointment) => appointment.id == appointmentId);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListenersSafely();
    }
    return updatedAppointment;
  }

  void updateLocalAppointment(Appointment updatedAppointment) {
    int index = _appointments
        .indexWhere((appointment) => appointment.id == updatedAppointment.id);
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      notifyListenersSafely();
    }
  }

  // Delete appointment
  Future<bool> deleteAppointment(int appointmentId) async {
    try {
      bool success = await _appointmentService.deleteAppointment(appointmentId);
      if (success) {
        _appointments
            .removeWhere((appointment) => appointment.id == appointmentId);
        notifyListenersSafely();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Fetch all appointments for a specific patient
  Future<void> fetchAllAppointmentsForPatient(int patientId) async {
    _isLoading = true;
    notifyListenersSafely();

    try {
      _appointments =
          await _appointmentService.fetchAllAppointmentsForPatient(patientId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

// Add treatment
  Future<bool> createTreatment(int appointmentId, int diagnosisId, Map<String, dynamic> treatmentData) async {
    try {
      final updatedTreatment = await _appointmentService.createTreatment(appointmentId, diagnosisId, treatmentData);
      appointments.firstWhere((a) => a.id == appointmentId)
          .diagnoses.firstWhere((d) => d.id == diagnosisId)
          .treatments.add(updatedTreatment);
      notifyListenersSafely();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListenersSafely();
      return false;
    }
  }

// Add prescription
  Future<bool> createPrescription(int appointmentId, int treatmentId, Map<String, dynamic> prescriptionData) async {
    final response = await _appointmentService.createPrescription(appointmentId, treatmentId, prescriptionData);
    final newPrescription = response;
    final treatment = _findTreatmentById(appointmentId, treatmentId);
    if (treatment != null) {
      treatment.prescriptions.add(newPrescription);
      notifyListenersSafely();
      return true;
    } else {
      return false;
    }
  }

  // Helper methods to find treatment and diagnosis by ID
  Treatment? _findTreatmentById(int appointmentId, int treatmentId) {
    // Find the matching appointment
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId,
        orElse: () => Appointment(
              id: -1,
              patient: Patient(
                id: -1,
                name: 'Unknown',
                egn: 'N/A',
                healthInsurancePaid: false,
                primaryDoctorId: -1,
                keycloakUserId: 'N/A',
              ),
              doctor: Doctor(
                id: -1,
                keycloakUserId: 'N/A',
                name: 'Unknown',
                specialties: 'N/A',
                primaryCare: false,
              ),
              appointmentDateTime: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: null,
              sickLeaves: [],
              diagnoses: [],
            ));
    // Find the matching treatment
    return appointment.diagnoses
        .expand((d) => d.treatments)
        .firstWhere((t) => t.id == treatmentId,
            orElse: () => Treatment(
                  id: -1,
                  description: '',
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  prescriptions: [],
                ));
  }

  // Update prescription
  Future<Prescription> updatePrescription(int appointmentId, int diagnosisId, int treatmentId, int prescriptionId, Map<String, dynamic> prescriptionData) async {
    try {
      Prescription updatedFetchedPrescription = await _appointmentService.updatePrescription(appointmentId, treatmentId, prescriptionId, prescriptionData);
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);
      final diagnosis = appointment.diagnoses.firstWhere((d) => d.id == diagnosisId);
      final treatment = diagnosis.treatments.firstWhere((t) => t.id == treatmentId);
      final prescriptionIndex = treatment.prescriptions.indexWhere((p) => p.id == prescriptionId);
      if (prescriptionIndex != -1) {
        treatment.prescriptions[prescriptionIndex] = updatedFetchedPrescription;
        notifyListenersSafely();
      }
      return updatedFetchedPrescription;
    } catch (e) {
      return Prescription(
        id: -1,
        medication: Medication(
          id: -1,
          medicationName: '',
          dosageForm: '',
          strength: '',
          sideEffect: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        dosage: '',
        duration: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

// Delete prescription
  Future<bool> deletePrescription(int appointmentId, int diagnosisId, int treatmentId, int prescriptionId) async {
    bool success = await _appointmentService.deletePrescription(appointmentId, treatmentId, prescriptionId);
    if (success) {
      appointments.firstWhere((a) => a.id == appointmentId)
          .diagnoses.firstWhere((d) => d.id == diagnosisId)
          .treatments.firstWhere((t) => t.id == treatmentId)
          .prescriptions.removeWhere((prescription) => prescription.id == prescriptionId);
      notifyListenersSafely();
    }
    return success;
  }

// Delete treatment
  Future<bool> deleteTreatment(int appointmentId, int diagnosisId, int treatmentId) async {
    bool success = await _appointmentService.deleteTreatment(appointmentId, treatmentId);
    if (success) {
      appointments.firstWhere((a) => a.id == appointmentId)
          .diagnoses.firstWhere((d) => d.id == diagnosisId)
          .treatments.removeWhere((treatment) => treatment.id == treatmentId);
      notifyListenersSafely();
    }
    return success;
  }

  // Update treatment
  Future<Treatment> updateTreatment(int appointmentId, int diagnosisId, int treatmentId, Map<String, dynamic> treatmentData) async {
    try {
      Treatment updatedFetchedTreatment = await _appointmentService.updateTreatment(appointmentId, treatmentId, treatmentData);
      final appointment = appointments.firstWhere((a) => a.id == appointmentId);
      final diagnosis = appointment.diagnoses.firstWhere((d) => d.id == diagnosisId);
      final treatmentIndex = diagnosis.treatments.indexWhere((t) => t.id == treatmentId);
      if (treatmentIndex != -1) {
        diagnosis.treatments[treatmentIndex] = updatedFetchedTreatment;
        notifyListenersSafely();
      }
      return updatedFetchedTreatment;
    } catch (e) {
      return Treatment(
        id: -1,
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        prescriptions: [],
      );
    }
  }

  Future<void> fetchAppointmentsForDoctor(int doctorId, DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    notifyListenersSafely();

    try {
      _appointments = await _appointmentService.fetchAppointmentsForDoctor(doctorId, startDate, endDate);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }}
