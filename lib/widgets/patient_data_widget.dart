import 'package:flutter/material.dart';
import '../domain/patient.dart';

class PatientDataWidget extends StatelessWidget {
  final Patient patient;
  final String primaryDoctorName;
  final String primaryDoctorSpecialties;
  final VoidCallback onTap;

  const PatientDataWidget({
    Key? key,
    required this.patient,
    required this.primaryDoctorName,
    required this.primaryDoctorSpecialties,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensures the column adapts to content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis, // Truncate if text is too long
                maxLines: 1,
              ),
              const SizedBox(height: 8.0),
              Text(
                'EGN: ${patient.egn}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Truncate if text is too long
              ),
              Text(
                'Health Insurance Paid: ${patient.healthInsurancePaid ? 'Yes' : 'No'}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Truncate if text is too long
              ),
              const SizedBox(height: 8.0),
              // Wrap ensures flexible layout and avoids overflow
              Expanded(
                child: Wrap(
                  runSpacing: 4.0,
                  children: [
                    Text(
                      'Primary Doctor: $primaryDoctorName',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Truncate if text is too long
                    ),
                    Text(
                      'Doctor Specialties: $primaryDoctorSpecialties',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Truncate if text is too long
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
