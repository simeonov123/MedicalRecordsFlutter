class SickLeave {
  final int id;
  final String reason;
  final DateTime todayDate;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SickLeave({
    required this.id,
    required this.reason,
    required this.todayDate,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SickLeave.fromJson(Map<String, dynamic> json) {
    return SickLeave(
      id: json['id'],
      reason: json['reason'],
      todayDate: DateTime.parse(json['todayDate']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}
