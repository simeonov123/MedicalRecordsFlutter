class Patient {
  final int id;
  final String name;
  final String egn;
  final bool healthInsurancePaid;
  final int primaryDoctorId;
  final String keycloakUserId;

  Patient({
    required this.id,
    required this.name,
    required this.egn,
    required this.healthInsurancePaid,
    required this.primaryDoctorId,
    required this.keycloakUserId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    int primaryDoctorId = 0;
    if (json['primaryDoctorId'] != null) {
      primaryDoctorId = json['primaryDoctorId'];
    }
    return Patient(
      id: json['id'],
      name: json['name'],
      egn: json['egn'],
      healthInsurancePaid: json['healthInsurancePaid'],
      primaryDoctorId: primaryDoctorId,
      keycloakUserId: json['keycloakUserId'],
    );
  }

  Patient copyWith({
    int? id,
    String? name,
    String? egn,
    bool? healthInsurancePaid,
    int? primaryDoctorId,
    String? keycloakUserId,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      egn: egn ?? this.egn,
      healthInsurancePaid: healthInsurancePaid ?? this.healthInsurancePaid,
      primaryDoctorId: primaryDoctorId ?? this.primaryDoctorId,
      keycloakUserId: keycloakUserId ?? this.keycloakUserId,
    );
  }
}