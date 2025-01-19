class User {
  String id;
  String username;
  String email;
  String role;
  bool emailVerified;
  String? egn;
  String? firstName;
  String? lastName;
  String? keycloakUserId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.emailVerified,
    this.egn,
    this.firstName,
    this.lastName,
    this.keycloakUserId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    // Make both Flutter fields hold the same Keycloak ID:
    id: json['id'] ?? '',              // We do NOT hardcode an empty string anymore!
    keycloakUserId: json['id'] ?? '',  // So that doctor updates won't crash
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? '',
    emailVerified: json['emailVerified'] ?? false,
    egn: json['egn'],
    firstName: json['firstName'],
    lastName: json['lastName'],
  );


  User copyWith({
    String? id,
    String? username,
    String? email,
    String? role,
    bool? emailVerified,
    String? egn,
    String? firstName,
    String? lastName,
    String? keycloakUserId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      egn: egn ?? this.egn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      keycloakUserId: keycloakUserId ?? this.keycloakUserId,
    );
  }
}