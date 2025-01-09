import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_records_frontend/widgets/sickLeave_dialog.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import 'diagnosis_dialog.dart';

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
            final createdDate = DateFormat('yyyy-MM-dd – kk:mm').format(appointment.createdAt);
            final updatedDate = appointment.updatedAt != null
                ? DateFormat('yyyy-MM-dd – kk:mm').format(appointment.updatedAt!)
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment ID: ${appointment.id}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Doctor: ${appointment.doctor.name}'),
                    Text('Created At: $createdDate'),
                    Text('Updated At: $updatedDate'),
                    const SizedBox(height: 16),
                    Text(
                      'Patient Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Name: ${appointment.patient.name}'),
                    Text('EGN: ${appointment.patient.egn}'),
                    const SizedBox(height: 16),
                    if (appointment.sickLeaves.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => SickLeaveDialog(sickLeaves: appointment.sickLeaves),
                          );
                        },
                        child: const Text('View Sick Leave Details'),
                      ),
                    if (appointment.diagnoses.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => DiagnosisDialog(diagnoses: appointment.diagnoses),
                          );
                        },
                        child: const Text('View Diagnosis Details'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
