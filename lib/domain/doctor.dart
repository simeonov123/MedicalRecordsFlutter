// lib/domain/doctor.dart

class Doctor {
  final int id;
  final String uniqueIdentifier;
  final String name;
  final String specialties;
  final bool primaryCare;

  Doctor({
    required this.id,
    required this.uniqueIdentifier,
    required this.name,
    required this.specialties,
    required this.primaryCare,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      uniqueIdentifier: json['uniqueIdentifier'],
      name: json['name'],
      specialties: json['specialties'],
      primaryCare: json['primaryCare'],
    );
  }
}
