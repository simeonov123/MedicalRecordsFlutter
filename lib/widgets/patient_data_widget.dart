// lib/widgets/patient_data_widget.dart

import 'package:flutter/material.dart';
import '../domain/patient.dart';

class PatientDataWidget extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onTap;

  const PatientDataWidget({Key? key, required this.patient, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EGN: ${patient.egn}'),
            Text('Health Insurance Paid: ${patient.healthInsurancePaid ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
