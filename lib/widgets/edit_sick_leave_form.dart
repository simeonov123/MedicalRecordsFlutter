import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/sick_leave.dart';
import '../provider/appointment_provider.dart';

class EditSickLeaveForm extends StatefulWidget {
  final int appointmentId;
  final SickLeave sickLeave;
  final Function(SickLeave) onUpdate;

  const EditSickLeaveForm({
    Key? key,
    required this.appointmentId,
    required this.sickLeave,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditSickLeaveFormState createState() => _EditSickLeaveFormState();
}

class _EditSickLeaveFormState extends State<EditSickLeaveForm> {
  final _formKey = GlobalKey<FormState>();
  late String _reason;
  late DateTime _todayDate;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _reason = widget.sickLeave.reason;
    _todayDate = widget.sickLeave.todayDate;
    _startDate = widget.sickLeave.startDate;
    _endDate = widget.sickLeave.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Sick Leave'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _reason,
              decoration: InputDecoration(labelText: 'Reason'),
              validator: (value) => value!.isEmpty ? 'Please enter a reason' : null,
              onSaved: (value) => _reason = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Today\'s Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _todayDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _todayDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(text: _todayDate.toLocal().toString().split(' ')[0]),
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
          child: Text('Update'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final sickLeaveData = {
        'reason': _reason,
        'todayDate': _todayDate.toIso8601String(),
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
      };
      final updatedSickLeave = await Provider.of<AppointmentProvider>(context, listen: false)
          .updateSickLeave(widget.appointmentId, widget.sickLeave.id, sickLeaveData);
      widget.onUpdate(updatedSickLeave);
      Navigator.pop(context);
    }
  }
}