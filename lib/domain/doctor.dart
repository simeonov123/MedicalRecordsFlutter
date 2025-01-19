class Doctor {
  final int id;
  final String keycloakUserId;
  final String name;
  final String specialties;
  final bool primaryCare;

  Doctor({
    required this.id,
    required this.keycloakUserId,
    required this.name,
    required this.specialties,
    required this.primaryCare,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      keycloakUserId: json['keycloakUserId'],
      name: json['name'],
      specialties: json['specialties'],
      primaryCare: json['primaryCare'],
    );
  }

  Doctor copyWith({
    int? id,
    String? keycloakUserId,
    String? name,
    String? specialties,
    bool? primaryCare,
  }) {
    return Doctor(
      id: id ?? this.id,
      keycloakUserId: keycloakUserId ?? this.keycloakUserId,
      name: name ?? this.name,
      specialties: specialties ?? this.specialties,
      primaryCare: primaryCare ?? this.primaryCare,
    );
  }
}