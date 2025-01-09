import 'package:medical_records_frontend/domain/patient.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';

import 'diagnosis.dart';
import 'doctor.dart';

class Appointment {
  final int id;
  final Patient patient;
  final Doctor doctor;
  final DateTime appointmentDateTime; // New attribute
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SickLeave> sickLeaves;
  final List<Diagnosis> diagnoses;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.appointmentDateTime, // New attribute
    required this.createdAt,
    this.updatedAt,
    required this.sickLeaves,
    required this.diagnoses,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patient: Patient.fromJson(json['patient']),
      doctor: Doctor.fromJson(json['doctor']),
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']), // New attribute
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      sickLeaves: (json['sickLeaves'] as List<dynamic>)
          .map((sickLeave) => SickLeave.fromJson(sickLeave))
          .toList(),
      diagnoses: (json['diagnoses'] as List<dynamic>)
          .map((diagnosis) => Diagnosis.fromJson(diagnosis))
          .toList(),
    );
  }
}