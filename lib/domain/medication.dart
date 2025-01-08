class Medication {
  final int id;
  final String medicationName;
  final String dosageForm;
  final String strength;
  final String sideEffect;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.medicationName,
    required this.dosageForm,
    required this.strength,
    required this.sideEffect,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      medicationName: json['medicationName'],
      dosageForm: json['dosageForm'],
      strength: json['strength'],
      sideEffect: json['sideEffect'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}
