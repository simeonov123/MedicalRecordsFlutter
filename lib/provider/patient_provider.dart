// lib/provider/patient_provider.dart

import 'package:flutter/foundation.dart';
import '../service/api_service.dart';

class PatientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Future<bool> assignPrimaryDoctor(String patientId, int doctorId) async {
    final resp = await _apiService.put('/patients/$patientId/primary-doctor/$doctorId');
    return resp.statusCode == 200;
  }
}