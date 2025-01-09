import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_records_frontend/widgets/treatment_dialog.dart';
import '../domain/diagnosis.dart';

class DiagnosisDialog extends StatelessWidget {
  final List<Diagnosis> diagnoses;

  const DiagnosisDialog({Key? key, required this.diagnoses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Diagnosis Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: diagnoses.length,
          itemBuilder: (context, index) {
            final diagnosis = diagnoses[index];
            return ListTile(
              title: Text('Diagnosis: ${diagnosis.statement}'),
              subtitle: Text('Diagnosed On: ${DateFormat('yyyy-MM-dd').format(diagnosis.diagnosedDate)}'),
              trailing: diagnosis.treatments.isNotEmpty
                  ? ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => TreatmentDialog(treatments: diagnosis.treatments),
                  );
                },
                child: const Text('View Treatment Details'),
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
