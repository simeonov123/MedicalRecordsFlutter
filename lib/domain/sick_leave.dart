// lib/domain/sick_leave.dart

class SickLeave {
  final int id;
  final int patientId;
  final int doctorId;
  final DateTime startDate;
  final DateTime endDate;

  SickLeave({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.startDate,
    required this.endDate,
  });

  factory SickLeave.fromJson(Map<String, dynamic> json) {
    return SickLeave(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
