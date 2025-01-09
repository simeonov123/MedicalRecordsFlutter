// lib/widgets/diagnosis_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';

class DiagnosisForm extends StatefulWidget {
  final int appointmentId;
  final List<dynamic>? existingDiagnoses; // Add this line

  const DiagnosisForm({Key? key, required this.appointmentId, this.existingDiagnoses}) : super(key: key);

  @override
  _DiagnosisFormState createState() => _DiagnosisFormState();
}

class _DiagnosisFormState extends State<DiagnosisForm> {
  final _formKey = GlobalKey<FormState>();
  String _statement = '';
  DateTime _diagnosedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Diagnosis'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Statement'),
              validator: (value) => value!.isEmpty ? 'Please enter a statement' : null,
              onSaved: (value) => _statement = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Diagnosed Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _diagnosedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _diagnosedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(text: _diagnosedDate.toLocal().toString().split(' ')[0]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Create'),
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
      await Provider.of<AppointmentProvider>(context, listen: false).createDiagnosis(widget.appointmentId, diagnosisData);
      Navigator.pop(context);
    }
  }
}