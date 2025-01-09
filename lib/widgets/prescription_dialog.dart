import 'package:flutter/material.dart';
import '../domain/prescription.dart';

class PrescriptionDialog extends StatelessWidget {
  final List<Prescription> prescriptions;

  const PrescriptionDialog({Key? key, required this.prescriptions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Prescription Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: prescriptions.length,
          itemBuilder: (context, index) {
            final prescription = prescriptions[index];
            return ListTile(
              title: Text('Dosage: ${prescription.dosage}'),
              subtitle: Text('Duration: ${prescription.duration} days'),
              trailing: ElevatedButton(
                onPressed: prescription.medication != null
                    ? () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Medication: ${prescription.medication.medicationName}'),
                      content: Text(
                        'Dosage Form: ${prescription.medication.dosageForm}\n'
                            'Strength: ${prescription.medication.strength}\n'
                            'Side Effects: ${prescription.medication.sideEffect}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
                    : null,
                child: const Text('Medication Info'),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
