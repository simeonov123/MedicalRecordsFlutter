import 'package:medical_records_frontend/domain/treatment.dart';

class Diagnosis {
  final int id;
  final String statement;
  final DateTime diagnosedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Treatment> treatments;

  Diagnosis({
    required this.id,
    required this.statement,
    required this.diagnosedDate,
    required this.createdAt,
    required this.updatedAt,
    required this.treatments,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      statement: json['statement'],
      diagnosedDate: DateTime.parse(json['diagnosedDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      treatments: (json['treatments'] as List<dynamic>?)
          ?.map((treatment) => Treatment.fromJson(treatment))
          .toList() ?? [],
    );
  }
}
