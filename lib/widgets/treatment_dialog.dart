// lib/widgets/treatment_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/treatment.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'prescription_dialog.dart';
import 'prescription_form.dart';
import 'edit_treatment_form.dart';

class TreatmentDialog extends StatelessWidget {
  final int appointmentId;
  final int diagnosisId;
  final String doctorKeycloakUserId;

  const TreatmentDialog({
    Key? key,
    required this.appointmentId,
    required this.diagnosisId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        // 1) Find the appointment in the provider
        final aptIndex = appointmentProvider.appointments
            .indexWhere((a) => a.id == appointmentId);

        if (aptIndex == -1) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Appointment not found.'),
              ),
            ),
          );
        }

        final appointment = appointmentProvider.appointments[aptIndex];

        // 2) Find the diagnosis
        final diagIndex = appointment.diagnoses
            .indexWhere((d) => d.id == diagnosisId);

        if (diagIndex == -1) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Diagnosis not found.'),
              ),
            ),
          );
        }

        final diagnosis = appointment.diagnoses[diagIndex];
        final treatments = diagnosis.treatments;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Treatment Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 3) Show the list of treatments from the provider
                  Expanded(
                    child: treatments.isEmpty
                        ? const Center(child: Text('No treatments found.'))
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: treatments.length,
                      itemBuilder: (context, index) {
                        final treatment = treatments[index];
                        return Card(
                          margin:
                          const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Treatment ID: ${treatment.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    'Description: ${treatment.description}'),
                                Text(
                                  'Start: ${DateFormat('yyyy-MM-dd').format(treatment.startDate)}',
                                ),
                                Text(
                                  'End: ${DateFormat('yyyy-MM-dd').format(treatment.endDate)}',
                                ),
                                const SizedBox(height: 12),

                                // 4) Action buttons (Add Prescription, Edit Treatment, Delete)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    if (authProvider.roles
                                        .contains('doctor') &&
                                        authProvider.keycloakUserId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                PrescriptionForm(
                                                  treatmentId: treatment.id,
                                                  appointmentId:
                                                  appointmentId,
                                                ),
                                          );
                                        },
                                        child: const Text(
                                            'Add Prescription'),
                                      ),
                                    const SizedBox(width: 8),

                                    if (authProvider.roles
                                        .contains('doctor') &&
                                        authProvider.keycloakUserId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                EditTreatmentForm(
                                                  appointmentId:
                                                  appointmentId,
                                                  treatment: treatment,
                                                  diagnosisId: diagnosisId,
                                                  onUpdate:
                                                      (updatedTreatment) {
                                                    // No manual setState needed.
                                                    // Provider rebuilds automatically.
                                                  },
                                                ),
                                          );
                                        },
                                        child: const Text(
                                            'Edit Treatment'),
                                      ),
                                    const SizedBox(width: 8),

                                    if (authProvider.roles
                                        .contains('doctor') &&
                                        authProvider.keycloakUserId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success =
                                          await Provider.of<
                                              AppointmentProvider>(
                                              context,
                                              listen: false)
                                              .deleteTreatment(
                                              appointmentId,
                                              diagnosisId,
                                              treatment.id);

                                          if (!success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to delete treatment'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Treatment deleted successfully'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                            'Delete Treatment'),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // If there are prescriptions, show a button to view them
                                if (treatment.prescriptions.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              PrescriptionDialog(
                                                appointmentId: appointmentId,
                                                treatmentId: treatment.id,
                                                doctorKeycloakUserId:
                                                doctorKeycloakUserId,
                                                diagnosisId: diagnosisId,
                                              ),
                                        );
                                      },
                                      child:
                                      const Text('View Prescriptions'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5) Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
