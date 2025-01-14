import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import '../domain/medication.dart';
import '../provider/medication_provider.dart';
import '../domain/prescription.dart';

class EditPrescriptionForm extends StatefulWidget {
  final int appointmentId;
  final int diagnosisId;
  final int treatmentId;
  final Prescription prescription;
  final Function(Prescription) onUpdate;

  const EditPrescriptionForm({
    Key? key,
    required this.appointmentId,
    required this.treatmentId,
    required this.prescription,
    required this.onUpdate, required this.diagnosisId,
  }) : super(key: key);

  @override
  _EditPrescriptionFormState createState() => _EditPrescriptionFormState();
}

class _EditPrescriptionFormState extends State<EditPrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _dosage;
  late int _duration;
  Medication? _selectedMedication;

  @override
  void initState() {
    super.initState();
    _dosage = widget.prescription.dosage;
    _duration = widget.prescription.duration;
    _selectedMedication = widget.prescription.medication;
    Provider.of<MedicationProvider>(context, listen: false).fetchMedications();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Prescription'),
      content: Consumer<MedicationProvider>(
        builder: (context, medicationProvider, child) {
          if (medicationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (medicationProvider.error != null) {
            return Center(child: Text('Error: ${medicationProvider.error}'));
          } else {
            final medications = medicationProvider.medications;

            // Ensure the selected medication is part of the list or nullify it if not found
            if (_selectedMedication != null &&
                !medications.contains(_selectedMedication)) {
              _selectedMedication = null;
            }

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Medication>(
                    decoration: const InputDecoration(labelText: 'Select Medication'),
                    value: _selectedMedication,
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
                    validator: (value) =>
                    value == null ? 'Please select a medication' : null,
                  ),
                  TextFormField(
                    initialValue: _dosage,
                    decoration: const InputDecoration(labelText: 'Dosage'),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a dosage' : null,
                    onSaved: (value) => _dosage = value!,
                  ),
                  TextFormField(
                    initialValue: _duration.toString(),
                    decoration: const InputDecoration(labelText: 'Duration (days)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter a duration' : null,
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
          child: const Text('Update'),
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
      final updatedPrescription = await Provider.of<AppointmentProvider>(
        context,
        listen: false,
      ).updatePrescription(
        widget.appointmentId,
        widget.diagnosisId,
        widget.treatmentId,
        widget.prescription.id,
        prescriptionData,
      );
      widget.onUpdate(updatedPrescription);
      Navigator.pop(context);
    }
  }
}
