import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/treatment.dart';
import '../provider/appointment_provider.dart';

class EditTreatmentForm extends StatefulWidget {
  final int appointmentId;
  final Treatment treatment;
  final int diagnosisId;
  final Function(Treatment) onUpdate;

  const EditTreatmentForm({
    Key? key,
    required this.appointmentId,
    required this.treatment,
    required this.onUpdate, required this.diagnosisId,
  }) : super(key: key);

  @override
  _EditTreatmentFormState createState() => _EditTreatmentFormState();
}

class _EditTreatmentFormState extends State<EditTreatmentForm> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _description = widget.treatment.description;
    _startDate = widget.treatment.startDate;
    _endDate = widget.treatment.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Treatment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            const SizedBox(height: 8),
            _buildDateField(
              context,
              label: 'Start Date',
              selectedDate: _startDate,
              onDateSelected: (pickedDate) {
                setState(() {
                  _startDate = pickedDate;
                  // Ensure the end date is not earlier than the start date
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate;
                  }
                });
              },
              firstDate: DateTime.now(),
            ),
            const SizedBox(height: 8),
            _buildDateField(
              context,
              label: 'End Date',
              selectedDate: _endDate,
              onDateSelected: (pickedDate) {
                setState(() {
                  _endDate = pickedDate;
                });
              },
              firstDate: _startDate, // Ensure end date cannot be before start date
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

  Widget _buildDateField(BuildContext context,
      {required String label,
        required DateTime selectedDate,
        required Function(DateTime) onDateSelected,
        required DateTime firstDate}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate.isAfter(firstDate) ? selectedDate : firstDate,
          firstDate: firstDate,
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      controller: TextEditingController(
        text: selectedDate.toLocal().toString().split(' ')[0],
      ),
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
      final updatedTreatment = await Provider.of<AppointmentProvider>(context, listen: false)
          .updateTreatment(widget.appointmentId, widget.diagnosisId, widget.treatment.id, treatmentData);
      widget.onUpdate(updatedTreatment);
      Navigator.pop(context);
    }
  }
}
