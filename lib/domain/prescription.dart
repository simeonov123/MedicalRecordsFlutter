import 'medication.dart';

class Prescription {
  final int id;
  final Medication medication;
  final String dosage;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.medication,
    required this.dosage,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      medication: Medication.fromJson(json['medication']),
      dosage: json['dosage'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}
