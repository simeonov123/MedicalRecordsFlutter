import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/treatment.dart';
import 'prescription_dialog.dart';

class TreatmentDialog extends StatelessWidget {
  final List<Treatment> treatments;

  const TreatmentDialog({Key? key, required this.treatments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Treatment Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: treatments.length,
          itemBuilder: (context, index) {
            final treatment = treatments[index];
            return ListTile(
              title: Text('Treatment ID: ${treatment.id}'),
              subtitle: Text(
                'Start: ${DateFormat('yyyy-MM-dd').format(treatment.startDate)}\n'
                    'End: ${DateFormat('yyyy-MM-dd').format(treatment.endDate)}',
              ),
              trailing: treatment.prescriptions.isNotEmpty
                  ? ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => PrescriptionDialog(prescriptions: treatment.prescriptions),
                  );
                },
                child: const Text('View Prescriptions'),
              )
                  : null,
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
