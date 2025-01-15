// lib/widgets/prescription_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/prescription.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'medication_dialog.dart';
import 'edit_prescription_form.dart';

class PrescriptionDialog extends StatelessWidget {
  final int appointmentId;
  final int diagnosisId;
  final int treatmentId;
  final String doctorKeycloakUserId;

  const PrescriptionDialog({
    Key? key,
    required this.appointmentId,
    required this.diagnosisId,
    required this.treatmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserKeycloakId = authProvider.keycloakUserId;

    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        // 1) Find the correct appointment
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

        // 2) Find the correct diagnosis
        final diagIndex =
        appointment.diagnoses.indexWhere((d) => d.id == diagnosisId);
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

        // 3) Find the correct treatment
        final treatIndex =
        diagnosis.treatments.indexWhere((t) => t.id == treatmentId);
        if (treatIndex == -1) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Treatment not found.'),
              ),
            ),
          );
        }

        final treatment = diagnosis.treatments[treatIndex];
        final prescriptions = treatment.prescriptions;

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
                    'Prescription Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 4) Show the current prescription list from provider
                  Expanded(
                    child: prescriptions.isEmpty
                        ? const Center(
                      child: Text('No prescriptions found.'),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: prescriptions.length,
                      itemBuilder: (context, index) {
                        final prescription = prescriptions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dosage: ${prescription.dosage}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    'Duration: ${prescription.duration} days'),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => MedicationDialog(
                                          medication:
                                          prescription.medication,
                                        ),
                                      );
                                    },
                                    child:
                                    const Text('Medication Info'),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Action buttons (Edit, Delete)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (authProvider.roles
                                        .contains('admin') ||
                                        (authProvider.roles
                                            .contains('doctor') &&
                                            currentUserKeycloakId ==
                                                doctorKeycloakUserId))
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) =>
                                                EditPrescriptionForm(
                                                  appointmentId:
                                                  appointmentId,
                                                  treatmentId: treatmentId,
                                                  diagnosisId: diagnosisId,
                                                  prescription: prescription,
                                                  onUpdate:
                                                      (updatedPrescription) {
                                                    // Rely on provider rebuild
                                                  },
                                                ),
                                          );
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    const SizedBox(width: 8),

                                    if (authProvider.roles
                                        .contains('admin') ||
                                        (authProvider.roles
                                            .contains('doctor') &&
                                            currentUserKeycloakId ==
                                                doctorKeycloakUserId))
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success =
                                          await Provider.of<
                                              AppointmentProvider>(
                                              context,
                                              listen: false)
                                              .deletePrescription(
                                            appointmentId,
                                            diagnosisId,
                                            treatmentId,
                                            prescription.id,
                                          );

                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Prescription deleted successfully'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to delete prescription'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
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
