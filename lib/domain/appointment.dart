// lib/domain/appointment.dart

class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final int diagnosisId;
  final String treatment;
  final int sickLeaveDays;
  final DateTime date;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.diagnosisId,
    required this.treatment,
    required this.sickLeaveDays,
    required this.date,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      diagnosisId: json['diagnosisId'],
      treatment: json['treatment'],
      sickLeaveDays: json['sickLeaveDays'],
      date: DateTime.parse(json['date']),
    );
  }
}
