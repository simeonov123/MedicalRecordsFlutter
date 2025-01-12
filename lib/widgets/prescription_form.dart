import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import '../domain/medication.dart';
import '../provider/medication_provider.dart';

class PrescriptionForm extends StatefulWidget {
  final int treatmentId;
  final int appointmentId;

  const PrescriptionForm({Key? key, required this.treatmentId, required this.appointmentId}) : super(key: key);

  @override
  _PrescriptionFormState createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  String _dosage = '';
  int _duration = 0;
  Medication? _selectedMedication;

  @override
  void initState() {
    super.initState();
    Provider.of<MedicationProvider>(context, listen: false).fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Prescription'),
      content: Consumer<MedicationProvider>(
        builder: (context, medicationProvider, child) {
          if (medicationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (medicationProvider.error != null) {
            return Center(child: Text('Error: ${medicationProvider.error}'));
          } else {
            final medications = medicationProvider.medications;
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Medication>(
                    decoration: const InputDecoration(labelText: 'Select Medication'),
                    items: medications.map((medication) {
                      return DropdownMenuItem<Medication>(
                        value: medication,
                        child: Text(medication.medicationName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMedication = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a medication' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Dosage'),
                    validator: (value) => value!.isEmpty ? 'Please enter a dosage' : null,
                    onSaved: (value) => _dosage = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Duration (days)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter a duration' : null,
                    onSaved: (value) => _duration = int.parse(value!),
                  ),
                ],
              ),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prescriptionData = {
        'medicationId': _selectedMedication!.id,
        'dosage': _dosage,
        'duration': _duration,
      };
      await Provider.of<AppointmentProvider>(context, listen: false)
          .createPrescription(widget.appointmentId, widget.treatmentId, prescriptionData);
      Navigator.pop(context);
    }
  }
}