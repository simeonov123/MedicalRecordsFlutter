import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/diagnosis.dart';
import '../provider/appointment_provider.dart';

class EditDiagnosisForm extends StatefulWidget {
  final int appointmentId;
  final Diagnosis diagnosis;
  final Function(Diagnosis) onUpdate;

  const EditDiagnosisForm({
    Key? key,
    required this.appointmentId,
    required this.diagnosis,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditDiagnosisFormState createState() => _EditDiagnosisFormState();
}

class _EditDiagnosisFormState extends State<EditDiagnosisForm> {
  final _formKey = GlobalKey<FormState>();
  late String _statement;
  late DateTime _diagnosedDate;

  @override
  void initState() {
    super.initState();
    _statement = widget.diagnosis.statement;
    _diagnosedDate = widget.diagnosis.diagnosedDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Diagnosis'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _statement,
              decoration: const InputDecoration(labelText: 'Statement'),
              validator: (value) => value!.isEmpty ? 'Please enter a statement' : null,
              onSaved: (value) => _statement = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Diagnosed Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _diagnosedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _diagnosedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: _diagnosedDate.toLocal().toString().split(' ')[0],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final diagnosisData = {
        'statement': _statement,
        'diagnosedDate': _diagnosedDate.toIso8601String(),
      };
      final updatedDiagnosis = await Provider.of<AppointmentProvider>(context, listen: false)
          .updateDiagnosis(widget.appointmentId, widget.diagnosis.id, diagnosisData);
      widget.onUpdate(updatedDiagnosis);
      Navigator.pop(context);
    }
  }
}