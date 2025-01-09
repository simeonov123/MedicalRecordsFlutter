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
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

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
            final appointmentDateTime = DateFormat('yyyy-MM-dd – kk:mm').format(appointment.appointmentDateTime);
            final updatedDate = appointment.updatedAt != null
                ? DateFormat('yyyy-MM-dd – kk:mm').format(appointment.updatedAt!)
                : 'N/A';

            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: isLargeScreen ? 32.0 : 16.0,
              ),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment ID: ${appointment.id}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('Doctor: ${appointment.doctor.name}'),
                      Text('Appointment date and time at: $appointmentDateTime'),

                      Text('Created At: $createdDate'),
                      Text('Updated At: $updatedDate'),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Patient Information',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${appointment.patient.name}'),
                      Text('EGN: ${appointment.patient.egn}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (appointment.sickLeaves.isNotEmpty)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        SickLeaveDialog(sickLeaves: appointment.sickLeaves),
                                  );
                                },
                                child: const Text('View Sick Leave Details',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          const SizedBox(width: 10),
                          if (appointment.diagnoses.isNotEmpty)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        DiagnosisDialog(diagnoses: appointment.diagnoses),
                                  );
                                },
                                child: const Text('View Diagnosis Details',
                                    style: TextStyle(color: Colors.white)
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
