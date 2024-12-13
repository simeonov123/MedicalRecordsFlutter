// lib/domain/patient.dart

class Patient {
  final int id;
  final String name;
  final String egn;
  final bool healthInsurancePaid;
  final int primaryDoctorId;

  Patient({
    required this.id,
    required this.name,
    required this.egn,
    required this.healthInsurancePaid,
    required this.primaryDoctorId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      egn: json['egn'],
      healthInsurancePaid: json['healthInsurancePaid'],
      primaryDoctorId: json['primaryDoctorId'],
    );
  }
}
