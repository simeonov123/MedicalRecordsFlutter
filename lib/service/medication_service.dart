import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/medication.dart';
import 'api_service.dart';

class MedicationService {
  final ApiService _apiService = ApiService();

  Future<List<Medication>> fetchMedications() async {
    final response = await _apiService.get('/medications');
    if (response.statusCode == 200) {
      List<dynamic> medicationsJson = json.decode(response.body);
      return medicationsJson.map((json) => Medication.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }
}