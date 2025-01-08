// lib/widgets/appointment_list_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import the intl package
import '../provider/appointment_provider.dart';

class AppointmentListWidget extends StatelessWidget {
  const AppointmentListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, child) {
        if (appointmentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appointmentProvider.appointments.isEmpty) {
          return const Center(child: Text('No appointments found.'));
        }

        return ListView.builder(
          itemCount: appointmentProvider.appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointmentProvider.appointments[index];
            final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(appointment.createdAt);

            return Card(
              child: ExpansionTile(
                title: Text('Appointment ID: ${appointment.id}'),
                subtitle: Text('Doctor: ${appointment.doctor.name}, Date: $formattedDate'),
                children: [
                  ListTile(
                    title: const Text('Patient Information'),
                    subtitle: Text('Name: ${appointment.patient.name}, EGN: ${appointment.patient.egn}'),
                  ),
                  ...appointment.diagnoses.map((diagnosis) {
                    return ListTile(
                      title: Text('Diagnosis: ${diagnosis.statement}'),
                      subtitle: Text('Diagnosed Date: ${DateFormat('yyyy-MM-dd').format(diagnosis.diagnosedDate)}'),
                    );
                  }).toList(),
                  ...appointment.sickLeaves.map((sickLeave) {
                    return ListTile(
                      title: Text('Sick Leave Reason: ${sickLeave.reason}'),
                      subtitle: Text(
                          'From: ${DateFormat('yyyy-MM-dd').format(sickLeave.startDate)} To: ${DateFormat('yyyy-MM-dd').format(sickLeave.endDate)}'),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}