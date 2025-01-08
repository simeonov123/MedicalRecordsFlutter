import 'package:medical_records_frontend/domain/patient.dart';
import 'package:medical_records_frontend/domain/sick_leave.dart';

import 'diagnosis.dart';
import 'doctor.dart';

class Appointment {
  final int id;
  final Patient patient;
  final Doctor doctor;
  final List<Diagnosis> diagnoses;
  final List<SickLeave> sickLeaves;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.diagnoses,
    required this.sickLeaves,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patient: Patient.fromJson(json['patient']),
      doctor: Doctor.fromJson(json['doctor']),
      diagnoses: (json['diagnoses'] as List<dynamic>?)
          ?.map((diagnosis) => Diagnosis.fromJson(diagnosis))
          .toList() ?? [],
      sickLeaves: (json['sickLeaves'] as List<dynamic>?)
          ?.map((sickLeave) => SickLeave.fromJson(sickLeave))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
