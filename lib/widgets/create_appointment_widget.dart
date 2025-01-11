// lib/widgets/create_appointment_widget.dart

import 'package:flutter/material.dart';
import 'package:medical_records_frontend/domain/doctor.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';

class CreateAppointmentWidget extends StatefulWidget {
  final List<Doctor> doctors;
  final int patientId;

  const CreateAppointmentWidget({Key? key, required this.doctors, required this.patientId}) : super(key: key);

  @override
  _CreateAppointmentWidgetState createState() => _CreateAppointmentWidgetState();
}

class _CreateAppointmentWidgetState extends State<CreateAppointmentWidget> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedDoctorId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Select Doctor'),
                items: widget.doctors
                    .map((doctor) => DropdownMenuItem<int>(
                  value: doctor.id, // Use the doctor's id as the value
                  child: Text(doctor.name), // Display the doctor's name
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value; // Assign the selected doctor's id
                  });
                },
                validator: (value) => value == null ? 'Please select a doctor' : null
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Select Date'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              validator: (value) => _selectedDate == null ? 'Please select a date' : null,
              controller: TextEditingController(
                text: _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : '',
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Select Time'),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
              validator: (value) => _selectedTime == null ? 'Please select a time' : null,
              controller: TextEditingController(
                text: _selectedTime != null ? _selectedTime!.format(context) : '',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  DateTime appointmentDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  bool success = await Provider.of<AppointmentProvider>(context, listen: false).createAppointment(
                    patientId: widget.patientId,
                    doctorId: _selectedDoctorId!,
                    date: appointmentDateTime,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment created successfully')),
                    );
                    Provider.of<AppointmentProvider>(context, listen: false).fetchAppointmentsForUser();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create appointment')),
                    );
                  }
                }
              },
              child: const Text('Create Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}