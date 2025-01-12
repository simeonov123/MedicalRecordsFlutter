import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';

class TreatmentForm extends StatefulWidget {
  final int diagnosisId;
  final int appointmentId;

  const TreatmentForm({Key? key, required this.diagnosisId, required this.appointmentId}) : super(key: key);

  @override
  _TreatmentFormState createState() => _TreatmentFormState();
}

class _TreatmentFormState extends State<TreatmentForm> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Treatment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Start Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _startDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(text: _startDate.toLocal().toString().split(' ')[0]),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'End Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _endDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(text: _endDate.toLocal().toString().split(' ')[0]),
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
      final treatmentData = {
        'description': _description,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
      };
      await Provider.of<AppointmentProvider>(context, listen: false).createTreatment(widget.appointmentId, widget.diagnosisId, treatmentData);
      Navigator.pop(context);
    }
  }
}