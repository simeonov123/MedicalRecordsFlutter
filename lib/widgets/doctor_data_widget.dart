// lib/widgets/doctor_data_widget.dart

import 'package:flutter/material.dart';
import '../domain/doctor.dart';

class DoctorDataWidget extends StatelessWidget {
  final Doctor doctor;

  const DoctorDataWidget({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialties: ${doctor.specialties.isNotEmpty ? doctor.specialties : 'N/A'}'),
            Text('Primary Care: ${doctor.primaryCare ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
