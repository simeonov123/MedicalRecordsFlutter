// lib/domain/diagnosis.dart

class Diagnosis {
  final int id;
  final String name;
  final String description;

  Diagnosis({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
