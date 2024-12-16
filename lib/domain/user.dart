class User {
  String id;
  String username;
  String email;
  String role;
  bool emailVerified;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? 'user',
    emailVerified: json['emailVerified'] == true,
  );
}
