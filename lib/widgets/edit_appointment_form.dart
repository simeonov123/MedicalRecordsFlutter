import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/appointment.dart';
import '../domain/doctor.dart';
import '../provider/appointment_provider.dart';
import '../provider/doctor_provider.dart';
import '../provider/auth_provider.dart';

class EditAppointmentForm extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment) onUpdate;

  const EditAppointmentForm({
    Key? key,
    required this.appointment,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditAppointmentFormState createState() => _EditAppointmentFormState();
}

class _EditAppointmentFormState extends State<EditAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int? _selectedDoctorId;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.appointmentDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.appointmentDateTime);
    _selectedDoctorId = widget.appointment.doctor.id;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

    return AlertDialog(
      title: const Text('Edit Appointment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Select Date'),
              readOnly: true,
              onTap: () async {
                DateTime firstDate = DateTime.now();
                DateTime initialDate = _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate;
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: _selectedDate.toLocal().toString().split(' ')[0],
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Select Time'),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
              controller: TextEditingController(
                text: _selectedTime.format(context),
              ),
            ),
            if (authProvider.roles.contains('admin'))
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Select Doctor'),
                value: _selectedDoctorId,
                items: doctorProvider.doctors
                    .map((doctor) => DropdownMenuItem<int>(
                  value: doctor.id,
                  child: Text(doctor.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a doctor' : null,
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
      DateTime updatedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedAppointment = await Provider.of<AppointmentProvider>(context,
          listen: false)
          .updateAppointment(
        widget.appointment.id,
        updatedDateTime,
        _selectedDoctorId,
      );
      widget.onUpdate(updatedAppointment);
      Navigator.pop(context);
    }
  }
}