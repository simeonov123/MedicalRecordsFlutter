// lib/widgets/sick_leave_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';

class SickLeaveForm extends StatefulWidget {
  final int appointmentId;
  final List<dynamic>? existingSickLeaves; // Add this line

  const SickLeaveForm({Key? key, required this.appointmentId, this.existingSickLeaves}) : super(key: key);

  @override
  _SickLeaveFormState createState() => _SickLeaveFormState();
}

class _SickLeaveFormState extends State<SickLeaveForm> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Sick Leave'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Reason'),
              validator: (value) => value!.isEmpty ? 'Please enter a reason' : null,
              onSaved: (value) => _reason = value!,
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
      final sickLeaveData = {
        'reason': _reason,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
      };
      await Provider.of<AppointmentProvider>(context, listen: false).createSickLeave(widget.appointmentId, sickLeaveData);
      Navigator.pop(context);
    }
  }
}