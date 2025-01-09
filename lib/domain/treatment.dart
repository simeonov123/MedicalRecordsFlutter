// lib/domain/treatment.dart

import 'prescription.dart';

class Treatment {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final List<Prescription> prescriptions;

  Treatment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.prescriptions,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      description: json['description'],
      prescriptions: (json['prescriptions'] as List<dynamic>?)
          ?.map((prescription) => Prescription.fromJson(prescription))
          .toList() ?? [],
    );
  }
}